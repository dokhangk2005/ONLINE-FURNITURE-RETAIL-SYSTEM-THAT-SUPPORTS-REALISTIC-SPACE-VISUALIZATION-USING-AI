using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProductsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/products
        [HttpGet]
        public async Task<IActionResult> GetProducts([FromQuery] bool includeDeleted = false)
        {
            var query = _context.Products.AsQueryable();
            if (includeDeleted && User.IsInRole("Admin"))
            {
                query = query.IgnoreQueryFilters();
            }
            else
            {
                query = query.Where(p => !p.IsDeleted);
            }

            var productSales = await _context.OrderDetails.IgnoreQueryFilters()
                .Include(od => od.ProductVariant)
                .Include(od => od.Order)
                .Where(od => od.Order != null && od.Order.OrderStatus != "Cancelled" && od.ProductVariant != null)
                .GroupBy(od => od.ProductVariant.ProductId)
                .Select(g => new { ProductId = g.Key, TotalSold = g.Sum(od => od.Quantity) })
                .ToDictionaryAsync(x => x.ProductId, x => x.TotalSold);

            var products = await query
                .Include(p => p.Category)
                .Include(p => p.ProductVariants!)
                    .ThenInclude(v => v.ProductImages)
                .ToListAsync();

            foreach (var p in products)
            {
                if (productSales.TryGetValue(p.ProductId, out var soldCount))
                {
                    p.SoldCount = soldCount;
                }
            }

            return Ok(products);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetProduct(int id)
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductVariants!).ThenInclude(v => v.ProductImages)
                .FirstOrDefaultAsync(p => p.ProductId == id && !p.IsDeleted);
            return product == null ? NotFound(new { Message = "Không tìm thấy sản phẩm." }) : Ok(product);
        }

        // POST: api/products
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateProduct([FromBody] Product product)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var discountError = ValidateDiscount(product);
            if (discountError != null)
                return BadRequest(new { Message = discountError });

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            if (string.IsNullOrEmpty(product.ProductCode))
            {
                var category = await _context.Categories.FindAsync(product.CategoryId);
                string prefix = category?.CategoryCode ?? "PROD";
                product.ProductCode = $"{prefix}-{product.ProductId:D3}";
                await _context.SaveChangesAsync();
            }

            return Ok(product);
        }

        // PUT: api/products/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] Product product)
        {
            var existingProduct = await _context.Products.IgnoreQueryFilters().FirstOrDefaultAsync(p => p.ProductId == id);
            if (existingProduct == null)
            {
                return NotFound(new { Message = "Không tìm thấy sản phẩm" });
            }

            existingProduct.ProductName = product.ProductName;
            existingProduct.ProductCode = product.ProductCode;
            existingProduct.BasePrice = product.BasePrice;
            var discountError = ValidateDiscount(product);
            if (discountError != null)
                return BadRequest(new { Message = discountError });
            existingProduct.DiscountPercent = product.DiscountPercent;
            existingProduct.IsDiscountActive = product.IsDiscountActive;
            existingProduct.DiscountStartAt = product.DiscountStartAt;
            existingProduct.DiscountEndAt = product.DiscountEndAt;
            existingProduct.Description = product.Description;
            existingProduct.CategoryId = product.CategoryId;
            existingProduct.IsDeleted = product.IsDeleted;
            existingProduct.UpdatedAt = DateTime.Now;

            // Cập nhật ProductVariants và ProductImages (Bảo lưu trọn vẹn VariantId để KHÔNG BỊ MẤT số lượng đã bán SoldCount & Lịch sử đơn hàng)
            var existingVariants = await _context.ProductVariants.IgnoreQueryFilters().Include(v => v.ProductImages).Where(v => v.ProductId == id).ToListAsync();
            var processedVariantIds = new HashSet<int>();

            if (product.ProductVariants != null)
            {
                foreach (var variant in product.ProductVariants)
                {
                    var existing = existingVariants.FirstOrDefault(v => v.VariantId == variant.VariantId && variant.VariantId > 0);
                    if (existing != null)
                    {
                        // Cập nhật thuộc tính trên biến thể hiện có (bảo lưu VariantId)
                        existing.Material = variant.Material;
                        existing.Color = variant.Color;
                        existing.Size = variant.Size;
                        existing.AdditionalPrice = variant.AdditionalPrice;
                        existing.StockQuantity = variant.StockQuantity;
                        existing.IsDeleted = variant.IsDeleted;
                        existing.UpdatedAt = DateTime.Now;

                        // Cập nhật hình ảnh sản phẩm cho biến thể này
                        if (existing.ProductImages != null && existing.ProductImages.Any())
                        {
                            _context.ProductImages.RemoveRange(existing.ProductImages);
                        }
                        if (variant.ProductImages != null)
                        {
                            foreach (var img in variant.ProductImages)
                            {
                                img.VariantId = existing.VariantId;
                                img.ImageId = 0;
                                _context.ProductImages.Add(img);
                            }
                        }
                        processedVariantIds.Add(existing.VariantId);
                    }
                    else
                    {
                        // Thêm mới biến thể nếu chưa có trong DB
                        variant.ProductId = id;
                        variant.VariantId = 0;
                        if (variant.ProductImages != null)
                        {
                            foreach (var img in variant.ProductImages)
                            {
                                img.ImageId = 0;
                            }
                        }
                        _context.ProductVariants.Add(variant);
                    }
                }
            }

            // Đối với biến thể cũ không còn nằm trong danh sách cập nhật mới:
            foreach (var toRemove in existingVariants.Where(v => !processedVariantIds.Contains(v.VariantId)))
            {
                // Kiểm tra nếu biến thể đã có lịch sử đơn hàng OrderDetails thì CHỈ chuyển sang Soft Delete (IsDeleted = true) để không xóa mất dữ liệu lượt bán
                bool hasOrders = await _context.OrderDetails.IgnoreQueryFilters().AnyAsync(od => od.VariantId == toRemove.VariantId);
                if (hasOrders)
                {
                    toRemove.IsDeleted = true;
                    toRemove.UpdatedAt = DateTime.Now;
                }
                else
                {
                    _context.ProductVariants.Remove(toRemove);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(existingProduct);
        }

        private static string? ValidateDiscount(Product product)
        {
            if (product.DiscountPercent < 0 || product.DiscountPercent > 90)
                return "Phần trăm giảm giá phải nằm trong khoảng từ 0 đến 90%.";
            if (product.IsDiscountActive && product.DiscountPercent <= 0)
                return "Sản phẩm bật giảm giá phải có phần trăm giảm lớn hơn 0.";
            if (product.DiscountStartAt.HasValue && product.DiscountEndAt.HasValue
                && product.DiscountEndAt.Value <= product.DiscountStartAt.Value)
                return "Thời gian kết thúc giảm giá phải sau thời gian bắt đầu.";
            return null;
        }

        // DELETE: api/products/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.IgnoreQueryFilters().FirstOrDefaultAsync(p => p.ProductId == id);
            if (product == null)
            {
                return NotFound(new { Message = "Không tìm thấy sản phẩm" });
            }

            // Xóa vĩnh viễn sản phẩm khỏi Database khi bấm nút Xóa
            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã xóa vĩnh viễn sản phẩm thành công" });
        }
    }
}

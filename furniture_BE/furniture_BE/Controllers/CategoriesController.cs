using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CategoriesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/categories
        [HttpGet]
        public async Task<IActionResult> GetCategories()
        {
            var categories = await _context.Categories
                .Include(c => c.SubCategories)
                .Where(c => !c.IsDeleted)
                .ToListAsync();

            return Ok(categories);
        }

        // POST: api/categories
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateCategory([FromBody] Category category)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrEmpty(category.CategoryCode))
            {
                string initials = GenerateInitials(category.CategoryName);
                string generatedCode = initials;

                if (category.ParentCategoryId.HasValue)
                {
                    var parent = await _context.Categories.FindAsync(category.ParentCategoryId.Value);
                    if (parent != null && !string.IsNullOrEmpty(parent.CategoryCode))
                    {
                        generatedCode = $"{parent.CategoryCode}-{initials}";
                    }
                }

                string finalCode = generatedCode;
                int counter = 1;
                while (await _context.Categories.AnyAsync(c => c.CategoryCode == finalCode && !c.IsDeleted))
                {
                    finalCode = $"{generatedCode}{counter}";
                    counter++;
                }

                category.CategoryCode = finalCode;
            }

            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return Ok(category);
        }

        // PUT: api/categories/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] Category category)
        {
            var existingCategory = await _context.Categories.FirstOrDefaultAsync(c => c.CategoryId == id && !c.IsDeleted);
            if (existingCategory == null)
            {
                return NotFound(new { Message = "Không tìm thấy danh mục" });
            }

            existingCategory.CategoryName = category.CategoryName;
            existingCategory.ImageUrl = category.ImageUrl;
            existingCategory.ParentCategoryId = category.ParentCategoryId;
            
            if (!string.IsNullOrEmpty(category.CategoryCode))
            {
                existingCategory.CategoryCode = category.CategoryCode;
            }
            
            existingCategory.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return Ok(existingCategory);
        }

        // DELETE: api/categories/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.Categories.FirstOrDefaultAsync(c => c.CategoryId == id);
            if (category == null || category.IsDeleted)
            {
                return NotFound(new { Message = "Không tìm thấy danh mục" });
            }

            var hasActiveChildren = await _context.Categories
                .AnyAsync(c => c.ParentCategoryId == id && !c.IsDeleted);
            var hasActiveProducts = await _context.Products
                .AnyAsync(p => p.CategoryId == id && !p.IsDeleted);
            if (hasActiveChildren || hasActiveProducts)
            {
                return Conflict(new
                {
                    Code = "CATEGORY_IN_USE",
                    Message = "Không thể xóa danh mục đang có danh mục con hoặc sản phẩm hoạt động."
                });
            }

            // Soft delete
            category.IsDeleted = true;
            category.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã xóa danh mục thành công" });
        }

        private static string GenerateInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "CAT";

            // Loại bỏ dấu tiếng Việt
            string normalized = name.Normalize(System.Text.NormalizationForm.FormD);
            var sb = new System.Text.StringBuilder();
            foreach (var c in normalized)
            {
                var category = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c);
                if (category != System.Globalization.UnicodeCategory.NonSpacingMark)
                {
                    sb.Append(c);
                }
            }
            string cleanName = sb.ToString().Normalize(System.Text.NormalizationForm.FormC).ToUpper();

            // Lấy ký tự đầu của từng từ
            var words = cleanName.Split(new[] { ' ', '-', '_' }, StringSplitOptions.RemoveEmptyEntries);
            return string.Concat(words.Select(w => w[0]));
        }
    }
}

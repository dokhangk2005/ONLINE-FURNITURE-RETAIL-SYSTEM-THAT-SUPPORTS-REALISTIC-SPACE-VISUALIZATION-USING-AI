import fs from "node:fs/promises";
import path from "node:path";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const TMP_DIR = "D:/KLTN/furniture_BE/.codex-tmp/defense-slides-20260819";
const ASSET_DIR = path.join(TMP_DIR, "assets");
const RENDER_DIR = path.join(TMP_DIR, "renders");
const FINAL_PPTX = "D:/KLTN/furniture_BE/BaoCao_BaoVe_KhoaLuan_MyFurnitureStore.pptx";

const C = {
  canvas: "#FFFFFF",
  ink: "#101828",
  muted: "#5B6472",
  panel: "#F2F4F7",
  panelBlue: "#EAF5FB",
  rule: "#B8BCC4",
  accent: "#3D8DFF",
  accentLight: "#DCEBFF",
  green: "#18A56A",
  amber: "#E99B2E",
  red: "#D94A4A",
  dark: "#1F2933",
};

const FONT = "Arial";
let objectCounter = 0;

function id(prefix) {
  objectCounter += 1;
  return `${prefix}-${objectCounter}`;
}

function addText(slide, text, position, options = {}) {
  const shape = slide.shapes.add({
    geometry: "textbox",
    name: options.name ?? id("text"),
    position,
    fill: "none",
    line: { style: "solid", fill: "none", width: 0 },
  });
  shape.text = text;
  shape.text.style = {
    fontSize: options.fontSize ?? 20,
    typeface: options.typeface ?? FONT,
    color: options.color ?? C.ink,
    bold: options.bold ?? false,
    italic: options.italic ?? false,
    alignment: options.alignment ?? "left",
    verticalAlignment: options.verticalAlignment ?? "top",
    autoFit: options.autoFit ?? "none",
    wrap: "square",
  };
  return shape;
}

function addBox(slide, position, options = {}) {
  const geometry = options.geometry ?? "roundRect";
  const config = {
    geometry,
    name: options.name ?? id("box"),
    position,
    fill: options.fill ?? C.panel,
    line: options.line ?? { style: "solid", fill: "none", width: 0 },
  };
  if (["rect", "textbox", "roundRect"].includes(geometry)) {
    config.borderRadius = options.borderRadius ?? "rounded-xl";
  }
  return slide.shapes.add(config);
}

function addLine(slide, left, top, width, color = C.rule, weight = 1) {
  return slide.shapes.add({
    geometry: "line",
    name: id("line"),
    position: { left, top, width, height: 1 },
    fill: "none",
    line: { style: "solid", fill: color, width: weight },
  });
}

function addArrow(slide, position, color = C.accent) {
  return slide.shapes.add({
    geometry: "rightArrow",
    name: id("arrow"),
    position,
    fill: color,
    line: { style: "solid", fill: "none", width: 0 },
  });
}

function addTitle(slide, title, number, eyebrow = "BẢO VỆ KHÓA LUẬN") {
  addText(slide, eyebrow, { left: 42, top: 30, width: 330, height: 24 }, {
    fontSize: 14,
    bold: true,
    color: C.accent,
  });
  addText(slide, title, { left: 42, top: 62, width: 1135, height: 76 }, {
    fontSize: 40,
    bold: true,
    color: C.ink,
  });
  addLine(slide, 42, 146, 1196, C.rule, 1);
  if (number != null) {
    addText(slide, String(number).padStart(2, "0"), { left: 1190, top: 669, width: 48, height: 20 }, {
      fontSize: 13,
      color: C.muted,
      alignment: "right",
    });
  }
}

function addBulletList(slide, items, position, options = {}) {
  const gap = options.gap ?? 52;
  const bulletSize = options.bulletSize ?? 10;
  items.forEach((item, index) => {
    const top = position.top + index * gap;
    addBox(slide, { left: position.left, top: top + 8, width: bulletSize, height: bulletSize }, {
      geometry: "ellipse",
      fill: options.bulletColor ?? C.accent,
      borderRadius: 0,
    });
    addText(slide, item, {
      left: position.left + 24,
      top,
      width: position.width - 24,
      height: options.itemHeight ?? 44,
    }, {
      fontSize: options.fontSize ?? 20,
      color: options.color ?? C.ink,
      bold: options.bold ?? false,
    });
  });
}

function addMetric(slide, value, label, left, top, width = 250, accent = C.accent) {
  addLine(slide, left, top, width, accent, 5);
  addText(slide, value, { left, top: top + 18, width, height: 62 }, {
    fontSize: 50,
    bold: true,
    color: C.ink,
  });
  addText(slide, label, { left, top: top + 84, width, height: 54 }, {
    fontSize: 18,
    color: C.muted,
  });
}

async function readImage(fileName) {
  return await fs.readFile(path.join(ASSET_DIR, fileName));
}

async function addImage(slide, fileName, alt, position, options = {}) {
  const bytes = await readImage(fileName);
  const ext = path.extname(fileName).toLowerCase();
  const contentType = ext === ".jpg" || ext === ".jpeg" ? "image/jpeg" : "image/png";
  return slide.images.add({
    blob: bytes,
    contentType,
    alt,
    fit: options.fit ?? "cover",
    crop: options.crop,
    geometry: options.geometry ?? "roundRect",
    borderRadius: options.borderRadius ?? "rounded-xl",
    position,
  });
}

function addNotes(slide, timing, lines, sources) {
  const sourceBlock = ["[Sources]", ...sources.map((source) => `- ${source}`), "[/Sources]"];
  slide.speakerNotes.textFrame.setText([
    `Thời lượng gợi ý: ${timing}`,
    ...lines,
    "",
    ...sourceBlock,
  ].join("\n"));
  slide.speakerNotes.setVisible(true);
}

function sourceReport() {
  return "C:/Users/vikha/Desktop/BaoCaoKhoaLuan_Final1.docx";
}

function backendSource(relative) {
  return `D:/KLTN/furniture_BE/furniture_BE/${relative}`;
}

function frontendSource(relative) {
  return `D:/KLTN/khoaluan/${relative}`;
}

function makePresentation() {
  return Presentation.create({ slideSize: { width: 1280, height: 720 } });
}

async function build() {
  await fs.mkdir(RENDER_DIR, { recursive: true });
  const presentation = makePresentation();

  // 01 — cover-image-field composition based on Codex Grid slide-08.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    await addImage(slide, "home-hero.png", "Trang chủ My Furniture Store", {
      left: 660, top: 42, width: 578, height: 590,
    }, { crop: { left: 0.03, top: 0, right: 0.03, bottom: 0 } });
    addText(slide, "BÁO CÁO KHÓA LUẬN TỐT NGHIỆP", { left: 42, top: 40, width: 560, height: 30 }, {
      fontSize: 16, bold: true, color: C.accent,
    });
    addText(slide, "Hệ thống bán lẻ nội thất trực tuyến hỗ trợ phối cảnh không gian thực bằng AI", {
      left: 42, top: 126, width: 555, height: 242,
    }, { fontSize: 50, bold: true, color: C.ink });
    addText(slide, "My Furniture Store", { left: 42, top: 389, width: 555, height: 38 }, {
      fontSize: 26, bold: true, color: C.accent,
    });
    addText(slide, "Đỗ Minh Vĩ Khang — 23DH114848\nTrần Ngọc Nhật Duy — 23DH110529", {
      left: 42, top: 480, width: 555, height: 74,
    }, { fontSize: 20, color: C.ink });
    addText(slide, "GVHD: ThS. Lương Văn Minh  |  TP.HCM, 08/2026", {
      left: 42, top: 592, width: 555, height: 30,
    }, { fontSize: 17, color: C.muted });
    addNotes(slide, "0:45", [
      "Kính chào Hội đồng. Nhóm trình bày kết quả nghiên cứu và triển khai hệ thống My Furniture Store.",
      "Điểm nhấn của đề tài là kết nối toàn bộ quy trình bán lẻ với tư vấn, đề xuất và phối cảnh nội thất bằng AI.",
    ], [sourceReport()]);
  }

  // 02 — roadmap.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Mạch trình bày đi từ bài toán đến minh chứng triển khai", 2);
    const labels = [
      ["01", "Bài toán & mục tiêu"],
      ["02", "Giải pháp & kiến trúc"],
      ["03", "AI & thuật toán"],
      ["04", "Kết quả & demo"],
      ["05", "Hạn chế & hướng phát triển"],
    ];
    addLine(slide, 100, 365, 1080, C.ink, 2);
    labels.forEach((entry, index) => {
      const left = 74 + index * 226;
      addBox(slide, { left: left + 35, top: 348, width: 34, height: 34 }, {
        geometry: "ellipse", fill: index === 3 ? C.accent : C.ink, borderRadius: 0,
      });
      addText(slide, entry[0], { left, top: 252, width: 104, height: 38 }, {
        fontSize: 28, bold: true, color: index === 3 ? C.accent : C.ink, alignment: "center",
      });
      addText(slide, entry[1], { left: left - 18, top: 414, width: 140, height: 72 }, {
        fontSize: 19, bold: true, color: C.ink, alignment: "center",
      });
    });
    addNotes(slide, "0:30", [
      "Trình bày tập trung vào kết quả có thể kiểm chứng trong báo cáo và source code.",
      "Phần demo nằm sau minh chứng triển khai để Hội đồng có đủ ngữ cảnh quan sát hệ thống.",
    ], [sourceReport()]);
  }

  // 03 — large message + three callouts based on slide-09.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Mua nội thất trực tuyến khó ở cả quyết định lẫn vận hành", 3);
    addText(slide, "Khách hàng cần hình dung sản phẩm trong chính căn phòng; cửa hàng cần đồng bộ bán hàng, kho, thanh toán và giao nhận trên cùng một luồng dữ liệu.", {
      left: 42, top: 178, width: 1170, height: 112,
    }, { fontSize: 26, color: C.ink });
    const cards = [
      ["Khó hình dung", "Ảnh sản phẩm rời rạc chưa trả lời được câu hỏi: có hợp với không gian thật hay không?"],
      ["Quy trình phân mảnh", "Sản phẩm, tồn kho, đơn hàng và thanh toán dễ tách rời nếu thiếu một hệ thống trung tâm."],
      ["Giao nhận phức tạp", "Nội thất cồng kềnh cần phân công, lắp đặt, chứng từ và xử lý sự cố xuyên suốt."],
    ];
    cards.forEach((card, index) => {
      const left = 42 + index * 410;
      addBox(slide, { left, top: 350, width: 372, height: 258 }, {
        fill: index === 0 ? C.panelBlue : C.panel,
      });
      addText(slide, `0${index + 1}`, { left: left + 28, top: 378, width: 60, height: 34 }, {
        fontSize: 24, bold: true, color: C.accent,
      });
      addText(slide, card[0], { left: left + 28, top: 434, width: 312, height: 42 }, {
        fontSize: 25, bold: true,
      });
      addText(slide, card[1], { left: left + 28, top: 495, width: 312, height: 88 }, {
        fontSize: 18, color: C.muted,
      });
    });
    addNotes(slide, "1:30", [
      "Nhấn mạnh đây không chỉ là bài toán xây một website bán hàng.",
      "Hai vấn đề gắn với nhau: giảm sự không chắc chắn khi chọn nội thất và giữ trạng thái nghiệp vụ thống nhất từ bán hàng đến giao nhận.",
    ], [sourceReport()]);
  }

  // 04 — objective and scope.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Mục tiêu và phạm vi triển khai", 4);
    addMetric(slide, "03", "vai trò sử dụng: Khách hàng, Admin, Shipper", 42, 216, 330, C.accent);
    addMetric(slide, "01", "quy trình dữ liệu xuyên suốt từ tìm kiếm đến giao hàng", 456, 216, 330, C.green);
    addMetric(slide, "02", "chế độ phối cảnh: điều chỉnh thủ công và AI tạo ảnh", 870, 216, 330, C.amber);
    addLine(slide, 42, 434, 1196, C.rule, 1);
    addText(slide, "Trong phạm vi", { left: 42, top: 464, width: 340, height: 36 }, {
      fontSize: 24, bold: true,
    });
    addBulletList(slide, [
      "Thương mại điện tử nội thất đầy đủ nghiệp vụ chính",
      "Đề xuất sản phẩm và phối cảnh trên ảnh phòng thật",
    ], { left: 42, top: 515, width: 520 }, { fontSize: 18, gap: 54 });
    addText(slide, "Ngoài phạm vi", { left: 670, top: 464, width: 340, height: 36 }, {
      fontSize: 24, bold: true,
    });
    addBulletList(slide, [
      "Huấn luyện mô hình AI chuyên biệt từ đầu",
      "Tối ưu hạ tầng cho quy mô người dùng rất lớn",
    ], { left: 670, top: 515, width: 520 }, { fontSize: 18, gap: 54, bulletColor: C.muted });
    addNotes(slide, "1:15", [
      "Làm rõ tiêu chí đánh giá: tính đúng đắn chức năng, khả năng tích hợp và tính khả thi của phối cảnh AI.",
      "Không tuyên bố độ chính xác kích thước tuyệt đối hay quy mô sản xuất lớn.",
    ], [sourceReport()]);
  }

  // 05 — three roles.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Một nền tảng kết nối ba vai trò quanh cùng đơn hàng", 5);
    const roles = [
      ["KHÁCH HÀNG", "Khám phá • chọn biến thể\nGiỏ hàng • VNPay • đánh giá\nTrợ lý AI • thiết kế phòng", C.accent],
      ["QUẢN TRỊ VIÊN", "Sản phẩm • tồn kho • voucher\nĐơn hàng • doanh thu • hỗ trợ\nĐề xuất • điều phối giao hàng", C.green],
      ["NHÂN VIÊN GIAO HÀNG", "Trạng thái ca làm\nNhận đơn • cập nhật kết quả\nBằng chứng • sự cố • hẹn lại", C.amber],
    ];
    addLine(slide, 216, 365, 850, C.rule, 2);
    roles.forEach((role, index) => {
      const left = 46 + index * 412;
      addBox(slide, { left, top: 216, width: 360, height: 330 }, { fill: C.panel });
      addBox(slide, { left: left + 28, top: 245, width: 54, height: 54 }, {
        geometry: "ellipse", fill: role[2], borderRadius: 0,
      });
      addText(slide, String(index + 1), { left: left + 28, top: 254, width: 54, height: 34 }, {
        fontSize: 24, bold: true, color: C.canvas, alignment: "center",
      });
      addText(slide, role[0], { left: left + 28, top: 326, width: 300, height: 32 }, {
        fontSize: 20, bold: true, color: role[2],
      });
      addText(slide, role[1], { left: left + 28, top: 390, width: 300, height: 110 }, {
        fontSize: 19, color: C.ink,
      });
    });
    addText(slide, "Trạng thái đơn hàng là điểm nối giữa trải nghiệm mua sắm và vận hành cửa hàng.", {
      left: 145, top: 594, width: 990, height: 42,
    }, { fontSize: 22, bold: true, alignment: "center" });
    addNotes(slide, "1:20", [
      "Mô tả ngắn chức năng mỗi vai trò, tránh liệt kê tất cả màn hình.",
      "Điểm quan trọng là cùng một đơn hàng được nhìn từ ba ngữ cảnh nhưng dùng chung trạng thái nghiệp vụ.",
    ], [sourceReport(), frontendSource("lib/services/api_service.dart")]);
  }

  // 06 — customer journey.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Hành trình khách hàng: từ khám phá đến hậu mãi", 6);
    const steps = [
      ["Tìm kiếm", "Autocomplete, lọc theo danh mục, màu, kích thước, giá"],
      ["Đánh giá", "Biến thể, tồn kho, đánh giá và sản phẩm gợi ý"],
      ["Quyết định", "Phối cảnh phòng, trợ lý AI, giỏ hàng và voucher"],
      ["Thanh toán", "Mapbox chuẩn hóa địa chỉ, VNPay hoặc COD"],
      ["Theo dõi", "Trạng thái đơn, đánh giá và hỗ trợ sau mua"],
    ];
    for (let index = 0; index < steps.length - 1; index += 1) {
      addArrow(slide, { left: 228 + index * 235, top: 330, width: 62, height: 28 }, C.accent);
    }
    steps.forEach((step, index) => {
      const left = 42 + index * 235;
      addBox(slide, { left, top: 245, width: 188, height: 246 }, {
        fill: index === 2 ? C.panelBlue : C.panel,
      });
      addText(slide, `0${index + 1}`, { left: left + 22, top: 270, width: 50, height: 32 }, {
        fontSize: 22, bold: true, color: C.accent,
      });
      addText(slide, step[0], { left: left + 22, top: 321, width: 144, height: 32 }, {
        fontSize: 23, bold: true,
      });
      addText(slide, step[1], { left: left + 22, top: 382, width: 144, height: 82 }, {
        fontSize: 17, color: C.muted,
      });
    });
    addText(slide, "Mỗi bước đều được ánh xạ thành API và trạng thái dữ liệu có thể tiếp tục ở bước kế tiếp.", {
      left: 170, top: 560, width: 940, height: 40,
    }, { fontSize: 22, bold: true, alignment: "center" });
    addNotes(slide, "1:20", [
      "Dùng một ví dụ đơn giản: khách tìm bàn ăn, xem thử trong phòng, đặt hàng và theo dõi giao nhận.",
      "Nhấn mạnh việc tự động cập nhật tồn kho và lịch sử đơn sau giao dịch.",
    ], [sourceReport(), frontendSource("lib/services/api_service.dart"), backendSource("Controllers/OrdersController.cs")]);
  }

  // 07 — simple native architecture diagram; arrows are authored before nodes.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Kiến trúc tách tương tác, nghiệp vụ, AI và dữ liệu", 7);
    addArrow(slide, { left: 330, top: 309, width: 72, height: 30 });
    addArrow(slide, { left: 655, top: 309, width: 72, height: 30 });
    addArrow(slide, { left: 962, top: 309, width: 72, height: 30 });
    addBox(slide, { left: 527, top: 456, width: 6, height: 74 }, { geometry: "rect", fill: C.accent, borderRadius: 0 });
    const nodes = [
      [42, 234, 290, 220, "FLUTTER CLIENT", "Giao diện responsive\nQuản lý trạng thái\nHTTP + SignalR"],
      [402, 234, 250, 220, "ASP.NET CORE", "116 endpoint\nJWT + phân quyền\nNghiệp vụ trung tâm"],
      [727, 234, 235, 220, "ENTITY FRAMEWORK", "19 thực thể\nTransaction\nSQL Server"],
      [1034, 234, 204, 220, "DỊCH VỤ NGOÀI", "VNPay • Mapbox\nGmail SMTP\nOpenAI • Gemini"],
      [402, 542, 250, 116, "FASTAPI AI", "ONNX Runtime • xử lý ảnh"],
    ];
    nodes.forEach((node, index) => {
      addBox(slide, { left: node[0], top: node[1], width: node[2], height: node[3] }, {
        fill: index === 1 || index === 4 ? C.panelBlue : C.panel,
      });
      const compact = index === 4;
      addText(slide, node[4], { left: node[0] + 24, top: node[1] + (compact ? 18 : 24), width: node[2] - 48, height: 34 }, {
        fontSize: index === 4 ? 18 : 20, bold: true, color: index === 1 || index === 4 ? C.accent : C.ink,
      });
      addText(slide, node[5], { left: node[0] + 24, top: node[1] + (compact ? 58 : 84), width: node[2] - 48, height: compact ? 36 : Math.max(28, node[3] - 104) }, {
        fontSize: 18, color: C.muted,
      });
    });
    addNotes(slide, "1:45", [
      "Đi từ trái sang phải theo một request thông thường.",
      "Khi có tác vụ AI, ASP.NET Core điều phối sang FastAPI hoặc nhà cung cấp tạo ảnh; client không truy cập trực tiếp khóa bí mật.",
      "Tách dịch vụ AI giúp thời gian chờ và tài nguyên suy luận không làm phức tạp toàn bộ backend.",
    ], [sourceReport(), backendSource("Program.cs"), backendSource("Data/AppDbContext.cs"), backendSource("ai_service/README.md")]);
  }

  // 08 — technology choices.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Mỗi công nghệ đảm nhiệm đúng loại tải công việc", 8);
    const items = [
      ["Flutter", "Một codebase cho web và các nền tảng; giao diện responsive và giàu tương tác."],
      ["ASP.NET Core", "API phân quyền, transaction nghiệp vụ và tích hợp dịch vụ bên thứ ba."],
      ["SQL Server", "Quan hệ dữ liệu chặt chẽ cho sản phẩm, đơn hàng, thanh toán và giao nhận."],
      ["FastAPI + ONNX", "Tách các tác vụ xóa nền, phân vùng và ước lượng chiều sâu có thời gian xử lý dài."],
    ];
    items.forEach((item, index) => {
      const left = 42 + index * 304;
      addLine(slide, left, 228, 260, index === 3 ? C.green : C.accent, 5);
      addText(slide, item[0], { left, top: 262, width: 260, height: 42 }, {
        fontSize: 27, bold: true,
      });
      addText(slide, item[1], { left, top: 337, width: 260, height: 138 }, {
        fontSize: 19, color: C.muted,
      });
    });
    addBox(slide, { left: 42, top: 532, width: 1196, height: 90 }, { fill: C.panelBlue });
    addText(slide, "Nguyên tắc thiết kế: client hiển thị — backend quyết định nghiệp vụ — dịch vụ AI xử lý ảnh — SQL Server bảo toàn dữ liệu.", {
      left: 72, top: 557, width: 1136, height: 40,
    }, { fontSize: 22, bold: true, alignment: "center" });
    addNotes(slide, "1:10", [
      "Giải thích lựa chọn theo trách nhiệm thay vì chỉ đọc danh sách công nghệ.",
      "SignalR được dùng cho hỗ trợ và giao hàng thời gian thực; các API ngoài được gọi qua backend.",
    ], [sourceReport(), backendSource("Program.cs"), frontendSource("pubspec.yaml")]);
  }

  // 09 — transaction and fulfillment timeline based on slide-17.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Ba lớp trạng thái bảo toàn vòng đời đơn hàng", 9);
    addLine(slide, 88, 352, 1070, C.ink, 2);
    const stages = [
      ["01 — TẠO ĐƠN", "Kiểm tra tồn kho", "Áp dụng voucher, phí giao hàng; transaction hoàn tác khi có lỗi."],
      ["02 — THANH TOÁN", "Xác minh kết quả", "VNPay được kiểm tra chữ ký, mã giao dịch và trạng thái trước khi ghi nhận."],
      ["03 — GIAO NHẬN", "Đóng vòng trạng thái", "Phân công shipper, bằng chứng giao hàng, thu hộ, sự cố và hẹn lại."],
    ];
    stages.forEach((stage, index) => {
      const left = 42 + index * 410;
      addText(slide, stage[0], { left, top: 266, width: 320, height: 30 }, {
        fontSize: 17, bold: true, color: C.accent,
      });
      addBox(slide, { left: left + 4, top: 339, width: 24, height: 24 }, {
        geometry: "ellipse", fill: C.ink, borderRadius: 0,
      });
      addText(slide, stage[1], { left, top: 408, width: 330, height: 36 }, {
        fontSize: 25, bold: true,
      });
      addText(slide, stage[2], { left, top: 467, width: 330, height: 92 }, {
        fontSize: 18, color: C.muted,
      });
    });
    addNotes(slide, "1:20", [
      "Nêu ví dụ tranh chấp tồn kho: transaction giúp tránh cập nhật nửa chừng.",
      "Quy trình giao hàng không dừng ở trạng thái 'đã giao' mà còn có thu hộ, đối soát và báo cáo sự cố.",
    ], [sourceReport(), backendSource("Controllers/OrdersController.cs"), backendSource("Controllers/DeliveryController.cs")]);
  }

  // 10 — recommendation evidence plus interpretation.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Hai cơ chế gợi ý bổ sung cho nhau", 10);
    addText(slide, "Apriori", { left: 42, top: 210, width: 220, height: 42 }, {
      fontSize: 28, bold: true, color: C.accent,
    });
    addText(slide, "Tìm sản phẩm thường xuất hiện cùng trong các đơn hợp lệ hoặc đã thanh toán.", {
      left: 42, top: 264, width: 430, height: 74,
    }, { fontSize: 20, color: C.ink });
    addText(slide, "Support", { left: 42, top: 367, width: 150, height: 30 }, {
      fontSize: 20, bold: true,
    });
    addText(slide, "mức độ phổ biến của cặp sản phẩm", { left: 190, top: 367, width: 280, height: 30 }, {
      fontSize: 18, color: C.muted,
    });
    addText(slide, "Confidence", { left: 42, top: 420, width: 150, height: 30 }, {
      fontSize: 20, bold: true,
    });
    addText(slide, "xác suất mua B khi đã mua A", { left: 190, top: 420, width: 280, height: 30 }, {
      fontSize: 18, color: C.muted,
    });
    addText(slide, "Content-based", { left: 42, top: 494, width: 220, height: 32 }, {
      fontSize: 22, bold: true, color: C.green,
    });
    addText(slide, "So khớp danh mục, màu sắc, kích thước và mức giá để vẫn có kết quả khi dữ liệu giao dịch còn ít.", {
      left: 42, top: 536, width: 430, height: 78,
    }, { fontSize: 18, color: C.muted });
    await addImage(slide, "recommendation-admin.png", "Trang quản trị thuật toán gợi ý", {
      left: 524, top: 190, width: 714, height: 438,
    }, { fit: "contain" });
    addNotes(slide, "1:30", [
      "Giải thích hai nhóm gợi ý được trình bày riêng để người dùng hiểu mục đích.",
      "Admin có thể bật/tắt từng phương pháp và điều chỉnh ngưỡng support, confidence trước khi xây lại luật.",
    ], [sourceReport(), backendSource("Services/RecommendationService.cs"), backendSource("Controllers/RecommendationsController.cs")]);
  }

  // 11 — AI pipeline.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Pipeline phối cảnh AI gồm sáu bước", 11);
    const top = [
      ["01", "Xóa nền", "U2NetP / rembg"],
      ["02", "Phân vùng", "SegFormer: sàn / tường"],
      ["03", "Chiều sâu", "Depth Anything V2"],
    ];
    const bottom = [
      ["04", "Đặt vật thể", "Mặt phẳng + tỷ lệ gần xa"],
      ["05", "Hòa cảnh", "Ánh sáng, bóng, phối cảnh"],
      ["06", "Che khuất", "Foreground + mask chỉnh sửa"],
    ];
    addArrow(slide, { left: 350, top: 268, width: 68, height: 28 });
    addArrow(slide, { left: 760, top: 268, width: 68, height: 28 });
    addArrow(slide, { left: 350, top: 500, width: 68, height: 28 }, C.green);
    addArrow(slide, { left: 760, top: 500, width: 68, height: 28 }, C.green);
    [...top, ...bottom].forEach((step, index) => {
      const row = index < 3 ? 0 : 1;
      const col = index % 3;
      const left = 42 + col * 410;
      const y = row === 0 ? 210 : 442;
      addBox(slide, { left, top: y, width: 330, height: 150 }, {
        fill: row === 0 ? C.panelBlue : C.panel,
      });
      addText(slide, step[0], { left: left + 24, top: y + 20, width: 52, height: 30 }, {
        fontSize: 20, bold: true, color: row === 0 ? C.accent : C.green,
      });
      addText(slide, step[1], { left: left + 24, top: y + 62, width: 280, height: 34 }, {
        fontSize: 24, bold: true,
      });
      addText(slide, step[2], { left: left + 24, top: y + 106, width: 280, height: 28 }, {
        fontSize: 17, color: C.muted,
      });
    });
    addNotes(slide, "2:00", [
      "Đây là đóng góp kỹ thuật nổi bật nhất, nên giải thích tuần tự sáu bước.",
      "Kết quả phân tích gồm mặt phẳng sàn/tường, lưới chiều sâu 32x24, lưới ánh sáng 16x12 và mặt nạ che khuất.",
      "AI tạo sinh OpenAI/Gemini là lớp tùy chọn sau khi đã có ảnh phòng và sản phẩm.",
    ], [sourceReport(), backendSource("ai_service/README.md"), backendSource("ai_service/app.py"), frontendSource("lib/page/visualizer/room_visualizer_page.dart")]);
  }

  // 12 — screenshot-led slide based on slide-08.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Người dùng kiểm soát, AI tăng độ chân thực", 12);
    await addImage(slide, "room-visualizer.png", "Giao diện phối cảnh không gian", {
      left: 42, top: 186, width: 810, height: 452,
    }, { fit: "contain" });
    addText(slide, "Hai chế độ bổ trợ", { left: 900, top: 212, width: 300, height: 38 }, {
      fontSize: 26, bold: true,
    });
    addBulletList(slide, [
      "Tự điều chỉnh: vị trí, kích thước, xoay, độ sáng và bóng",
      "AI tạo ảnh: OpenAI hoặc Gemini hòa sản phẩm vào căn phòng",
      "Lưu thiết kế, tải lại và xuất ảnh kết quả",
    ], { left: 900, top: 286, width: 310 }, { fontSize: 18, gap: 88, itemHeight: 76 });
    addBox(slide, { left: 900, top: 540, width: 310, height: 100 }, { fill: C.panelBlue });
    addText(slide, "AI là phương án tham khảo; người dùng vẫn có thể hiệu chỉnh khi nhận diện chưa chính xác.", {
      left: 920, top: 552, width: 270, height: 76,
    }, { fontSize: 16, bold: true, color: C.accent });
    addNotes(slide, "1:30", [
      "Chỉ rõ các điều khiển nằm ở cột bên phải và hai chế độ ở phía trên canvas.",
      "Nêu cơ chế người dùng sửa bốn góc mặt phẳng hoặc mask che khuất khi AI nhận diện sai.",
    ], [sourceReport(), frontendSource("lib/page/visualizer/room_visualizer_page.dart"), frontendSource("lib/model/room_analysis.dart")]);
  }

  // 13 — security, ownership, caching.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Bảo mật và toàn vẹn được thiết kế xuyên suốt", 13);
    const groups = [
      ["XÁC THỰC & PHÂN QUYỀN", ["JWT có thời hạn", "BCrypt cho mật khẩu", "Customer • Admin • Shipper"], C.accent],
      ["TOÀN VẸN GIAO DỊCH", ["Transaction khi tạo đơn", "Xác minh chữ ký VNPay", "Kiểm tra quyền sở hữu dữ liệu"], C.green],
      ["AI & HIỆU NĂNG", ["Access token cho thiết kế ẩn danh", "ETag + Cache-Control", "Đổi OpenAI/Gemini bằng cấu hình"], C.amber],
    ];
    groups.forEach((group, index) => {
      const left = 42 + index * 410;
      addLine(slide, left, 212, 370, group[2], 5);
      addText(slide, group[0], { left, top: 252, width: 370, height: 36 }, {
        fontSize: 20, bold: true, color: group[2],
      });
      addBulletList(slide, group[1], { left, top: 330, width: 360 }, {
        fontSize: 19, gap: 75, bulletColor: group[2], itemHeight: 54,
      });
    });
    addBox(slide, { left: 42, top: 578, width: 1196, height: 62 }, { fill: C.panel });
    addText(slide, "Các khóa bí mật được giữ ở backend; Flutter chỉ nhận dữ liệu và URL kết quả cần thiết.", {
      left: 72, top: 596, width: 1136, height: 32,
    }, { fontSize: 21, bold: true, alignment: "center" });
    addNotes(slide, "1:20", [
      "Không đi sâu vào từng lớp mã nguồn; nhóm các biện pháp theo ba mục tiêu.",
      "Nhấn mạnh access token ngẫu nhiên cho thiết kế chưa đăng nhập và thời hạn 24 giờ.",
    ], [sourceReport(), backendSource("Program.cs"), backendSource("Controllers/RoomDesignsController.cs"), backendSource("Services/ImageHarmonizationService.cs")]);
  }

  // 14 — customer evidence.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Luồng chức năng khách hàng đã hoàn thiện", 14);
    addText(slide, "Sản phẩm và quyết định mua", { left: 42, top: 190, width: 420, height: 36 }, {
      fontSize: 25, bold: true,
    });
    addBulletList(slide, [
      "Tìm kiếm, lọc và chọn biến thể",
      "Giỏ hàng, voucher, Mapbox và VNPay",
      "Lịch sử đơn, đánh giá và hỗ trợ",
    ], { left: 42, top: 250, width: 390 }, { fontSize: 19, gap: 62 });
    addText(slide, "Tư vấn trong đúng ngữ cảnh", { left: 42, top: 485, width: 420, height: 36 }, {
      fontSize: 25, bold: true, color: C.accent,
    });
    addText(slide, "Trợ lý AI đọc dữ liệu sản phẩm để trả lời về giá, đặc điểm, phối màu và bố trí không gian.", {
      left: 42, top: 535, width: 390, height: 86,
    }, { fontSize: 18, color: C.muted });
    await addImage(slide, "product-detail.png", "Trang chi tiết sản phẩm", {
      left: 472, top: 186, width: 766, height: 288,
    }, { fit: "contain" });
    await addImage(slide, "ai-chatbot.png", "Trợ lý AI nội thất", {
      left: 820, top: 495, width: 280, height: 170,
    }, { fit: "contain" });
    addNotes(slide, "1:10", [
      "Dùng ảnh thật để chứng minh luồng khách hàng đã có giao diện triển khai.",
      "Không dừng ở chatbot chung; trợ lý được đặt ngay trong trải nghiệm mua sắm và có dữ liệu sản phẩm.",
    ], [sourceReport(), frontendSource("lib/page/product/product_detail_page.dart"), backendSource("Controllers/ChatbotController.cs")]);
  }

  // 15 — operational evidence.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Admin và shipper khép kín vận hành sau đặt hàng", 15);
    const visuals = [
      ["admin-dashboard.png", "Admin", "Theo dõi tổng quan và đơn hàng"],
      ["delivery-control.png", "Điều phối", "Phân ca, theo dõi tải và xử lý sự cố"],
      ["shipper-orders.png", "Shipper", "Nhận đơn, cập nhật trạng thái và bằng chứng"],
    ];
    for (let index = 0; index < visuals.length; index += 1) {
      const left = 42 + index * 410;
      await addImage(slide, visuals[index][0], visuals[index][2], {
        left, top: 206, width: 370, height: 274,
      }, { fit: "contain" });
      addText(slide, visuals[index][1], { left, top: 514, width: 370, height: 34 }, {
        fontSize: 24, bold: true, color: index === 1 ? C.accent : C.ink,
      });
      addText(slide, visuals[index][2], { left, top: 560, width: 370, height: 58 }, {
        fontSize: 18, color: C.muted,
      });
    }
    addNotes(slide, "1:20", [
      "Giải thích vòng trạng thái: Admin xác nhận và phân công; Shipper nhận đơn, cập nhật hoặc báo sự cố; Admin tiếp nhận để hẹn lại.",
      "SignalR cập nhật sự kiện hỗ trợ và giao hàng theo thời gian thực.",
    ], [sourceReport(), backendSource("Controllers/DeliveryController.cs"), backendSource("Services/DeliveryRealtimeNotifier.cs"), frontendSource("lib/page/shipper/shipper_home_page.dart")]);
  }

  // 16 — verified implementation.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Kết quả triển khai đã được kiểm chứng", 16);
    addMetric(slide, "19", "controller backend", 42, 216, 250, C.accent);
    addMetric(slide, "116", "endpoint HTTP", 350, 216, 250, C.green);
    addMetric(slide, "19", "thực thể dữ liệu", 658, 216, 250, C.amber);
    addMetric(slide, "44", "kiểm thử tự động đã đạt", 966, 216, 250, C.accent);
    addLine(slide, 42, 426, 1196, C.rule, 1);
    addBox(slide, { left: 42, top: 478, width: 570, height: 132 }, { fill: C.panelBlue });
    addText(slide, "Backend build", { left: 72, top: 504, width: 230, height: 32 }, {
      fontSize: 22, bold: true, color: C.accent,
    });
    addText(slide, "Thành công • 0 cảnh báo • 0 lỗi", { left: 72, top: 552, width: 490, height: 34 }, {
      fontSize: 24, bold: true,
    });
    addBox(slide, { left: 668, top: 478, width: 570, height: 132 }, { fill: C.panel });
    addText(slide, "Kiểm thử", { left: 698, top: 504, width: 230, height: 32 }, {
      fontSize: 22, bold: true, color: C.green,
    });
    addText(slide, "40 Flutter + 4 xử lý ảnh AI", { left: 698, top: 552, width: 490, height: 34 }, {
      fontSize: 24, bold: true,
    });
    addNotes(slide, "1:20", [
      "Các số liệu được đếm từ source code trong workspace, không lấy từ ước lượng.",
      "Kết quả kiểm thử được chạy lại trước khi tạo slide: 40 test Flutter và 4 test xử lý ảnh đều đạt.",
      "Không khẳng định đây là kiểm thử tải hoặc kiểm thử bảo mật chuyên sâu.",
    ], [backendSource("Controllers"), backendSource("Data/AppDbContext.cs"), frontendSource("test"), backendSource("ai_service/test_scene_utils.py")]);
  }

  // 17 — demo timeline.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Demo tập trung vào ba điểm tạo nên giá trị của hệ thống", 17);
    addLine(slide, 88, 352, 1070, C.ink, 2);
    const demo = [
      ["PHẦN 1", "Khách hàng", "Tìm sản phẩm → xem thử trong phòng → thêm vào giỏ"],
      ["PHẦN 2", "Đặt hàng", "Mapbox → voucher → thanh toán → trạng thái đơn"],
      ["PHẦN 3", "Vận hành", "Admin phân công → shipper cập nhật → báo cáo sự cố"],
    ];
    demo.forEach((item, index) => {
      const left = 42 + index * 410;
      addText(slide, item[0], { left, top: 266, width: 220, height: 30 }, {
        fontSize: 18, bold: true, color: C.accent,
      });
      addBox(slide, { left: left + 4, top: 339, width: 24, height: 24 }, {
        geometry: "ellipse", fill: index === 1 ? C.accent : C.ink, borderRadius: 0,
      });
      addText(slide, item[1], { left, top: 408, width: 330, height: 40 }, {
        fontSize: 27, bold: true,
      });
      addText(slide, item[2], { left, top: 470, width: 330, height: 82 }, {
        fontSize: 19, color: C.muted,
      });
    });
    addBox(slide, { left: 220, top: 596, width: 840, height: 52 }, { fill: C.panelBlue });
    addText(slide, "Kịch bản dự phòng: dùng ảnh giao diện trong các slide trước nếu môi trường demo mất kết nối dịch vụ ngoài.", {
      left: 245, top: 608, width: 790, height: 30,
    }, { fontSize: 18, bold: true, color: C.accent, alignment: "center" });
    addNotes(slide, "5:30", [
      "Chuẩn bị sẵn tài khoản khách hàng, Admin và Shipper ở ba tab trình duyệt.",
      "Phần 1: mở sản phẩm bàn ăn, chọn biến thể, vào Room Design và thao tác một điều khiển phối cảnh.",
      "Phần 2: thêm giỏ, áp voucher, chọn địa chỉ; chỉ mở sandbox VNPay nếu kết nối ổn định.",
      "Phần 3: Admin xác nhận/phân công, Shipper nhận đơn và mở báo cáo sự cố.",
    ], [sourceReport(), frontendSource("lib/services/api_service.dart")]);
  }

  // 18 — limitations and roadmap.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "Hạn chế hiện tại xác định rõ hướng nghiên cứu tiếp theo", 18);
    const columns = [
      ["ĐỘ CHÍNH XÁC PHỐI CẢNH", "Phụ thuộc góc chụp, ánh sáng và chưa bảo đảm tỷ lệ kích thước tuyệt đối.", "3D / AR, hiệu chuẩn camera và bộ dữ liệu kiểm thử đa dạng hơn."],
      ["CÁ NHÂN HÓA GỢI Ý", "Apriori cần thêm lịch sử giao dịch; chưa có hồ sơ sở thích từng người dùng.", "Thu thập lượt xem, tìm kiếm, giỏ hàng; thử lọc cộng tác hoặc mô hình lai."],
      ["SẴN SÀNG VẬN HÀNH LỚN", "Phụ thuộc quota dịch vụ ngoài; chưa kiểm thử tải và bảo mật chuyên sâu.", "Cloud, giám sát, retry, quản lý secret và tối ưu định tuyến giao hàng."],
    ];
    columns.forEach((column, index) => {
      const left = 42 + index * 410;
      addText(slide, column[0], { left, top: 210, width: 370, height: 46 }, {
        fontSize: 19, bold: true, color: C.accent,
      });
      addText(slide, "Hiện tại", { left, top: 304, width: 140, height: 30 }, {
        fontSize: 18, bold: true, color: C.muted,
      });
      addText(slide, column[1], { left, top: 344, width: 370, height: 104 }, {
        fontSize: 18, color: C.ink,
      });
      addLine(slide, left, 470, 370, C.rule, 1);
      addText(slide, "Bước tiếp theo", { left, top: 495, width: 180, height: 30 }, {
        fontSize: 18, bold: true, color: C.green,
      });
      addText(slide, column[2], { left, top: 536, width: 370, height: 92 }, {
        fontSize: 18, color: C.muted,
      });
    });
    addNotes(slide, "1:20", [
      "Trình bày thẳng các giới hạn để định vị đúng mức độ hoàn thiện của khóa luận.",
      "Mỗi hạn chế được nối với một hướng phát triển cụ thể, có thể kiểm chứng trong giai đoạn tiếp theo.",
    ], [sourceReport()]);
  }

  // 19 — conclusion.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addTitle(slide, "AI được tích hợp vào quy trình bán lẻ hoàn chỉnh", 19);
    addText(slide, "My Furniture Store không tách AI thành một tính năng trình diễn; hệ thống đặt AI vào đúng thời điểm khách cần ra quyết định và vẫn giữ được quy trình vận hành phía sau.", {
      left: 42, top: 188, width: 1150, height: 110,
    }, { fontSize: 28, color: C.ink });
    const takeaways = [
      ["Giá trị người dùng", "Tìm, chọn, xem thử và đặt hàng trong một hành trình."],
      ["Giá trị kỹ thuật", "Kiến trúc nhiều dịch vụ, phân quyền và xử lý ảnh có thể mở rộng."],
      ["Giá trị vận hành", "Admin và shipper cùng quản lý trạng thái đến khi giao hàng hoàn tất."],
    ];
    takeaways.forEach((takeaway, index) => {
      const left = 42 + index * 410;
      addLine(slide, left, 370, 370, index === 1 ? C.green : C.accent, 5);
      addText(slide, takeaway[0], { left, top: 410, width: 370, height: 36 }, {
        fontSize: 23, bold: true,
      });
      addText(slide, takeaway[1], { left, top: 476, width: 370, height: 86 }, {
        fontSize: 19, color: C.muted,
      });
    });
    addText(slide, "Kết quả hiện tại là nền tảng khả thi để tiếp tục đánh giá bằng dữ liệu người dùng thực tế.", {
      left: 150, top: 612, width: 980, height: 34,
    }, { fontSize: 22, bold: true, color: C.accent, alignment: "center" });
    addNotes(slide, "0:50", [
      "Khép lại bằng cách trả lời đúng bài toán mở đầu: hỗ trợ quyết định mua và đồng bộ vận hành.",
      "Không lặp lại toàn bộ danh sách chức năng; giữ ba kết luận về người dùng, kỹ thuật và vận hành.",
    ], [sourceReport()]);
  }

  // 20 — closing based on Codex Grid slide-26.
  {
    const slide = presentation.slides.add();
    slide.background.fill = C.canvas;
    addText(slide, "BẢO VỆ KHÓA LUẬN", { left: 42, top: 42, width: 300, height: 36 }, {
      fontSize: 20, bold: true, color: C.accent,
    });
    addText(slide, "Cảm ơn Hội đồng", { left: 42, top: 182, width: 990, height: 145 }, {
      fontSize: 78, bold: true, color: C.ink,
    });
    addText(slide, "Nhóm xin lắng nghe câu hỏi và góp ý", { left: 42, top: 366, width: 800, height: 62 }, {
      fontSize: 32, color: C.muted,
    });
    addText(slide, "Đỗ Minh Vĩ Khang\nTrần Ngọc Nhật Duy", { left: 42, top: 532, width: 420, height: 94 }, {
      fontSize: 25, bold: true, color: C.ink,
    });
    addBox(slide, { left: 1030, top: 482, width: 208, height: 160 }, { fill: C.panelBlue });
    addText(slide, "Q&A", { left: 1030, top: 525, width: 208, height: 70 }, {
      fontSize: 54, bold: true, color: C.accent, alignment: "center",
    });
    addNotes(slide, "Phần còn lại", [
      "Mời Hội đồng đặt câu hỏi.",
      "Ưu tiên trả lời theo cấu trúc: quyết định thiết kế → bằng chứng trong source code → giới hạn hiện tại.",
    ], [sourceReport()]);
  }

  // Render every slide and save inspectable layout files.
  for (const [index, slide] of presentation.slides.items.entries()) {
    const stem = `slide-${String(index + 1).padStart(2, "0")}`;
    const png = await presentation.export({ slide, format: "png", scale: 1.5 });
    await fs.writeFile(path.join(RENDER_DIR, `${stem}.png`), new Uint8Array(await png.arrayBuffer()));
    const layout = await slide.export({ format: "layout" });
    await fs.writeFile(path.join(RENDER_DIR, `${stem}.layout.json`), await layout.text(), "utf8");
  }

  const montage = await presentation.export({ format: "webp", montage: true, scale: 1 });
  await fs.writeFile(path.join(TMP_DIR, "deck-montage.webp"), new Uint8Array(await montage.arrayBuffer()));

  const snapshot = await presentation.inspect({
    kind: "slide,textbox,shape,image,notes",
    maxChars: 60000,
  });
  await fs.writeFile(path.join(TMP_DIR, "deck-inspect.ndjson"), snapshot.ndjson, "utf8");

  let pptx;
  try {
    pptx = await PresentationFile.exportPptx(presentation);
  } catch (error) {
    const proto = presentation.toProto();
    let low = 1;
    let high = presentation.slides.items.length;
    while (low < high) {
      const mid = Math.floor((low + high) / 2);
      const probe = Presentation.load(proto);
      for (let index = probe.slides.items.length - 1; index >= mid; index -= 1) {
        probe.slides.remove(index);
      }
      try {
        await PresentationFile.exportPptx(probe);
        low = mid + 1;
      } catch {
        high = mid;
      }
    }
    console.error(`First failing slide prefix ends at slide ${low}.`);
    throw error;
  }
  await pptx.save(FINAL_PPTX);
  console.log(JSON.stringify({ finalPptx: FINAL_PPTX, slides: presentation.slides.items.length, renderDir: RENDER_DIR }, null, 2));
}

build().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

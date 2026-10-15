class NavItem {
  final String title;
  final String route;

  const NavItem({required this.title, required this.route});
}

class CategoryItem {
  final String title;
  final String image;
  final String route;

  const CategoryItem({
    required this.title,
    required this.image,
    required this.route,
  });
}

class ProductItem {
  final String title;
  final String image;
  final String price;
  final String route;

  const ProductItem({
    required this.title,
    required this.image,
    required this.price,
    required this.route,
  });
}

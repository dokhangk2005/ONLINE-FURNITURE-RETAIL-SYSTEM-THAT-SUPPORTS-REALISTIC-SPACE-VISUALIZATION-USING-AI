import 'package:flutter/material.dart';
import '../conf/responsive.dart';
import '../l10n/l10n.dart';

class SharedFooter extends StatelessWidget {
  const SharedFooter({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      color: const Color(0xffe5e5e5),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 80,
        isSmall ? 25 : 45,
        isMobile ? 16 : 80,
        isSmall ? 30 : 50,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FooterBrand(isSmall: isSmall),
                const SizedBox(height: 24),
                FooterExplore(isSmall: isSmall),
                const SizedBox(height: 24),
                FooterContact(isSmall: isSmall),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: FooterBrand(isSmall: isSmall)),
                const SizedBox(width: 40),
                Expanded(flex: 3, child: FooterExplore(isSmall: isSmall)),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: FooterContact(isSmall: isSmall)),
              ],
            ),
    );
  }
}

class FooterBrand extends StatelessWidget {
  const FooterBrand({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My',
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 32 : 48,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            height: 0.9,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: isSmall ? 36 : 54),
          child: Text(
            'FURNITURE',
            style: TextStyle(
              color: Colors.black,
              fontSize: isSmall ? 11 : 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(height: isSmall ? 12 : 20),
        Text(
          context.l10n.footerDescription,
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 11 : 13,
            height: 1.5,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class FooterExplore extends StatelessWidget {
  const FooterExplore({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.exploreMore,
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 14 : 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: isSmall ? 12 : 20),
        FooterLink(
          title: context.l10n.home,
          isSmall: isSmall,
          onTap: () => Navigator.pushNamed(context, '/'),
        ),
        FooterLink(
          title: context.l10n.navAbout,
          isSmall: isSmall,
          onTap: () => Navigator.pushNamed(context, '/about'),
        ),
        FooterLink(
          title: context.l10n.navProducts,
          isSmall: isSmall,
          onTap: () => Navigator.pushNamed(context, '/products'),
        ),
        FooterLink(
          title: context.l10n.navContact,
          isSmall: isSmall,
          onTap: () => Navigator.pushNamed(context, '/contact'),
        ),
      ],
    );
  }
}

class FooterContact extends StatelessWidget {
  const FooterContact({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.contactUs,
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 14 : 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: isSmall ? 12 : 20),
        FooterContactRow(
          icon: Icons.phone,
          text: '+84 909 27 3336',
          isSmall: isSmall,
        ),
        SizedBox(height: isSmall ? 8 : 12),
        FooterContactRow(
          icon: Icons.email,
          text: 'contact@myfurniture.com',
          isSmall: isSmall,
        ),
        SizedBox(height: isSmall ? 8 : 12),
        FooterContactRow(
          icon: Icons.location_on,
          text: context.l10n.companyAddress,
          isSmall: isSmall,
        ),
      ],
    );
  }
}

class FooterLink extends StatefulWidget {
  const FooterLink({
    super.key,
    required this.title,
    required this.onTap,
    this.isSmall = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSmall;

  @override
  State<FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<FooterLink> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHover = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.isSmall ? 6 : 10),
          child: Text(
            widget.title,
            style: TextStyle(
              color: isHover ? Colors.brown : Colors.black,
              fontSize: widget.isSmall ? 11 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              decoration: isHover ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }
}

class FooterContactRow extends StatelessWidget {
  const FooterContactRow({
    super.key,
    required this.icon,
    required this.text,
    this.isSmall = false,
  });

  final IconData icon;
  final String text;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black, size: isSmall ? 13 : 16),
        SizedBox(width: isSmall ? 8 : 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: isSmall ? 11 : 13,
              height: 1.5,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

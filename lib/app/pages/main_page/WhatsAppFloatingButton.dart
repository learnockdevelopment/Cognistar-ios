import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/colors.dart';
import '../../services/storage_service.dart';
import '../../widgets/main_widget/support_widget/support_widget.dart';

class FloatingActionButtonMenu extends StatelessWidget {
  void _launchWhatsApp() async {
    String? whatsappNumber = await StorageService.getWhatsAppNumber();
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      var url = "https://wa.me/$whatsappNumber";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _launchSupport() async {
    await SupportWidget.newSupportMessageSheet();
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.grid_view_rounded, // Grid-like menu icon
      activeIcon: Icons.close_rounded,
      backgroundColor: green77(),
      overlayColor: Colors.black,
      overlayOpacity: 0.6,
      spacing: 14,
      spaceBetweenChildren: 14,
      elevation: 0,
      buttonSize: const Size(60, 60), // Larger FAB
      childrenButtonSize: const Size(65, 65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Custom Rounded Square FAB
      ),
      children: [
        _buildCustomSpeedDialChild(
          icon: Icons.support_agent_rounded,
          label: appText.support,
          color: Colors.blueAccent,
          shape: BoxShape.circle, // Square
          onTap: _launchSupport,
        ),
        _buildCustomSpeedDialChild(
          icon: FontAwesomeIcons.whatsapp,
          label: 'WhatsApp',
          color: Colors.green.shade600,
          shape: BoxShape.circle, // Circular
          onTap: _launchWhatsApp,
        ),
      ],
    );
  }

  SpeedDialChild _buildCustomSpeedDialChild({
    required IconData icon,
    required String label,
    required Color color,
    required BoxShape shape,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: shape,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
      backgroundColor: Colors.transparent,
      label: label,
      labelStyle: const TextStyle(
        fontSize: 18, // Increased font size
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      elevation: 0,
      onTap: onTap,
    );
  }
}

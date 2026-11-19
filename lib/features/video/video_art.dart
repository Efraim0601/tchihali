import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Illustrations provisoires des écrans de visio (en attendant de vraies vidéos).
const _selfCam = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 340" preserveAspectRatio="xMidYMid slice">
<rect width="350" height="340" fill="#C9D6C3"/><rect width="120" height="340" fill="#BCCBB6"/>
<circle cx="175" cy="150" r="52" fill="#7A5038"/>
<path d="M120 140c0-42 30-64 55-64s55 22 55 64c-10-22-30-30-55-30s-45 8-55 30z" fill="#2E2420"/>
<path d="M78 340c8-80 50-112 97-112s89 32 97 112z" fill="#E39A6F"/></svg>''';

const _thumb = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 104 140" preserveAspectRatio="xMidYMid slice">
<rect width="104" height="140" fill="#C9D6C3"/><circle cx="52" cy="62" r="24" fill="#7A5038"/>
<path d="M26 58c0-20 14-30 26-30s26 10 26 30c-5-10-14-14-26-14s-21 4-26 14z" fill="#2E2420"/>
<path d="M12 140c4-34 22-50 40-50s36 16 40 50z" fill="#E39A6F"/></svg>''';

const _scene = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 844" preserveAspectRatio="xMidYMid slice">
<defs><linearGradient id="fade" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="#2F3437" stop-opacity="0"/><stop offset="1" stop-color="#2F3437" stop-opacity="0.75"/></linearGradient></defs>
<rect width="390" height="844" fill="#DCE6D6"/><rect width="390" height="520" fill="#E9E3D6"/>
<rect x="34" y="120" width="110" height="150" rx="10" fill="#F6F1E7" stroke="#D5CBB8" stroke-width="4"/>
<path d="M60 240c10-40 30-70 60-80-4 40-24 70-60 80z" fill="#8FB394"/>
<rect x="290" y="300" width="60" height="90" rx="8" fill="#C97B4E"/>
<path d="M320 300c-30-40-20-90 0-110 20 20 30 70 0 110z" fill="#6E9A77"/>
<circle cx="195" cy="380" r="86" fill="#5A3826"/>
<path d="M100 360c0-80 50-120 95-120s95 40 95 120c-14-40-50-60-95-60s-81 20-95 60z" fill="#1F1714"/>
<path d="M120 300c10-50 40-70 75-70s65 20 75 70c-20-20-45-28-75-28s-55 8-75 28z" fill="#E0704F"/>
<path d="M40 844c10-190 80-280 155-280s145 90 155 280z" fill="#F4F1EA"/>
<rect x="0" y="600" width="390" height="244" fill="url(#fade)"/></svg>''';

class SelfCamArt extends StatelessWidget {
  const SelfCamArt({super.key});
  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_selfCam, fit: BoxFit.cover);
}

class SelfThumbArt extends StatelessWidget {
  const SelfThumbArt({super.key});
  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_thumb, fit: BoxFit.cover);
}

class DietitianSceneArt extends StatelessWidget {
  const DietitianSceneArt({super.key});
  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_scene, fit: BoxFit.cover);
}

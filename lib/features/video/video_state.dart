import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Micro et caméra, partagés entre la salle d'attente et la téléconsultation.
class CallControls {
  const CallControls({this.mic = true, this.cam = true});
  final bool mic;
  final bool cam;
}

class CallControlsNotifier extends Notifier<CallControls> {
  @override
  CallControls build() => const CallControls();
  void toggleMic() => state = CallControls(mic: !state.mic, cam: state.cam);
  void toggleCam() => state = CallControls(mic: state.mic, cam: !state.cam);
  void reset() => state = const CallControls();
}

final callControlsProvider =
    NotifierProvider<CallControlsNotifier, CallControls>(
      CallControlsNotifier.new,
    );

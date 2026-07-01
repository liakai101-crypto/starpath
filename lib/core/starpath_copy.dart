enum StarPathLanguage { english, traditionalChinese }

class StarPathCopy {
  const StarPathCopy(this.language);

  final StarPathLanguage language;

  bool get isZh => language == StarPathLanguage.traditionalChinese;

  String get languageButton => isZh ? 'EN' : '\u7e41\u4e2d';
  String get orbit => isZh ? '\u661f\u57df' : 'Orbit';
  String get base => isZh ? '\u57fa\u5730' : 'Base';
  String get capsule => isZh ? '\u81a0\u56ca' : 'Capsule';
  String get command => isZh ? '\u6307\u63ee\u8266' : 'Command';
  String get launchPulse => isZh ? '\u767c\u5c04\u8108\u885d' : 'Launch Pulse';
  String get cooling => isZh ? '\u6563\u71b1\u4e2d' : 'Cooling';
  String get fleetFilter => isZh ? '\u7de8\u968a\u904e\u6ffe' : 'Fleet filter';
  String get allBands => isZh ? '\u5168\u983b\u6bb5' : 'All bands';
  String get singularity => isZh ? '\u5947\u9ede' : 'Singularity';

  String formation(String name) {
    if (!isZh) {
      return switch (name) {
        'All' => 'All bands',
        _ => name,
      };
    }

    return switch (name) {
      'All' => '\u5168\u983b\u6bb5',
      'Research' => '\u7814\u7a76',
      'Sport' => '\u904b\u52d5',
      'Design' => '\u8a2d\u8a08',
      'Cross-field' => '\u8de8\u9818\u57df',
      _ => name,
    };
  }

  String get hubbleName => isZh ? '\u54c8\u4f2f' : 'Hubble';
  String get hubbleIdle => isZh
      ? '\u8266\u9577\uff0c\u57fa\u5730\u5f85\u547d\u4e2d\u3002\u9ede\u4e00\u4e0b\u52a0\u5bc6\u98db\u8239\uff0c\u6211\u5c31\u53bb\u5e6b\u4f60\u805e\u51fa\u8a0a\u865f\u3002\u6c6a\u3002'
      : 'Captain, the base is standing by. Tap an encrypted ship and I will sniff the signal. Woof.';
  String get hubbleEncrypted => isZh
      ? '\u6211\u627e\u5230\u4e00\u5c01\u52a0\u5bc6\u4fe1\u3002\u9ede\u6211\u4e00\u4e0b\uff0c\u6211\u4f86\u5e6b\u4f60\u89e3\u958b\u3002\u6c6a\u3002'
      : 'I found an encrypted letter. Tap me and I will decrypt it. Woof.';
  String get hubbleDecrypted => isZh
      ? '\u89e3\u5bc6\u5b8c\u6210\u3002\u4f60\u53ef\u4ee5\u554f\u4ed6\uff1a\u300c\u6700\u8fd1\u6709\u4ec0\u9ebc\u5f88\u5c0f\uff0c\u4f46\u610f\u5916\u8b93\u4f60\u5fc3\u60c5\u8b8a\u597d\u7684\u4e8b\uff1f\u300d'
      : 'Decrypted: try asking, "What is one small thing that unexpectedly made your day better lately?"';
  String get hubbleCooling => isZh
      ? '\u5f15\u64ce\u6b63\u5728\u6563\u71b1\u3002\u5148\u559d\u53e3\u6c34\uff0c\u8b93\u98db\u8239\u5598\u4e00\u4e0b\u3002\u6c6a\u3002'
      : 'The engine is cooling. Drink some water and let the ship breathe. Woof.';
  String get hubbleSleep => isZh
      ? '\u8266\u9577\u6b63\u5728\u6df1\u7a7a\u51ac\u7720\u4e2d\u3002\u5168\u8266\u7cfb\u7d71\u5b89\u5168\u5f85\u547d\uff0c\u7b49\u4f60\u60f3\u518d\u770b\u661f\u7a7a\u6642\u518d\u53eb\u9192\u6211\u3002\u6c6a\u3002'
      : 'Captain is in deep-space hibernation. All systems are safe. Wake me when you want the stars again. Woof.';
  String get hubbleWake => isZh
      ? '\u6b61\u8fce\u56de\u822a\u3002\u7de9\u885d\u80fd\u91cf\u5df2\u88dc\u4e0a\uff0c\u57fa\u5730\u91cd\u65b0\u9ede\u4eae\u3002\u6c6a\u3002'
      : 'Welcome back. Buffer energy released and the base is bright again. Woof.';

  String get signalCabin => isZh ? '\u8a0a\u865f\u8259' : 'Signal cabin';
  String get icebreakerSignal => isZh ? '\u7834\u51b0\u8a0a\u865f' : 'Icebreaker Signal';
  String get sharedMemoryOrbit => isZh ? '\u5171\u540c\u56de\u61b6\u8ecc\u9053' : 'Shared memory orbit';
  String get timeline => isZh ? '\u6642\u9593\u8ef8' : 'Timeline';
  String get energyLocked => isZh ? '\u80fd\u91cf\u9396\u5b9a' : 'Energy locked';
  String get waitingForGravity => isZh ? '\u7b49\u5f85\u5f15\u529b\u56de\u61c9\u3002' : 'Waiting for gravity.';
  String get quantum => isZh ? '\u958b\u555f\u87f2\u6d1e' : 'Open Wormhole';
  String get hibernate => isZh ? '\u51ac\u7720' : 'Hibernate';
  String get wake => isZh ? '\u559a\u9192' : 'Wake';
  String get singularityStatus => isZh ? '\u5947\u9ede\u72c0\u614b' : 'Singularity status';
  String get badgeWall => isZh ? '\u52f3\u7ae0\u7246' : 'Badge Wall';
  String get shareOrbit => isZh ? '\u5206\u4eab\u8ecc\u9053' : 'Share Orbit';
  String get copyShareCard => isZh ? '\u8907\u88fd\u5206\u4eab\u5361' : 'Copy share card';
  String get copiedToClipboard => isZh ? '\u5df2\u8907\u88fd\u5230\u526a\u8cbc\u7c3f' : 'Copied to clipboard';
  String get profileReady => isZh ? '\u540d\u7247\u5df2\u5c31\u7dd2' : 'Profile ready';
  String get recorded => isZh ? '\u5df2\u8a18\u9304' : 'Recorded';
  String get locked => isZh ? '\u672a\u89e3\u9396' : 'Locked';
  String get unlocked => isZh ? '\u5df2\u89e3\u9396' : 'Unlocked';
  String get firstOrbit => isZh ? '\u7b2c\u4e00\u689d\u8ecc\u9053' : 'First Orbit';
  String get firstCoordinate => isZh ? '\u7b2c\u4e00\u500b\u5ea7\u6a19' : 'First Coordinate';
  String get singularityCore => isZh ? '\u5947\u9ede\u6838\u5fc3' : 'Singularity Core';
  String get ceoSignal => isZh
      ? '\u5275\u8fa6\u4eba\u8266\u9577\u7a81\u5165\u901a\u8a0a\uff1a\u4f60\u5df2\u9ede\u4eae\u7b2c\u4e00\u679a\u5947\u9ede\u6838\u5fc3\u3002'
      : 'Founder Captain transmission: you lit the first Singularity Core.';
  String get linkInBio => isZh ? 'Instagram \u500b\u4eba\u540d\u7247' : 'Instagram Link-in-Bio';
  String get relationshipWorkbench => isZh ? '\u95dc\u4fc2\u5de5\u4f5c\u53f0' : 'Relationship workbench';
  String get relationshipArchive => isZh ? '\u95dc\u4fc2\u6a94\u6848\u5eab' : 'Relationship archive';
  String get nextAction => isZh ? '\u4e0b\u4e00\u6b65\u884c\u52d5' : 'Next action';
  String get socialFeed => isZh ? '\u793e\u4ea4\u901a\u8a0a\u6d41' : 'Social signal feed';
  String get primary => isZh ? '\u4e3b\u8981' : 'Primary';
  String get general => isZh ? '\u4e00\u822c' : 'General';
  String get requests => isZh ? '\u8acb\u6c42' : 'Requests';
  String get stories => isZh ? '\u52d5\u614b' : 'Stories';
  String get yourMessages => isZh ? '\u4f60\u7684\u8a0a\u606f' : 'Your messages';
  String get privateMessages => isZh ? '\u79c1\u8a0a\u548c\u5171\u4eab\u8a0a\u865f\u90fd\u5728\u9019\u88e1\u3002' : 'Private messages and shared signals live here.';
  String get sendMessage => isZh ? '\u50b3\u9001\u8a0a\u606f' : 'Send message';
  String get noNewSignals => isZh ? '\u76ee\u524d\u9084\u6c92\u6709\u65b0\u8a0a\u865f' : 'No new signals yet';
  String get noPendingRequests => isZh ? '\u76ee\u524d\u6c92\u6709\u5f85\u8655\u7406\u8acb\u6c42' : 'No pending requests';
  String get waitingForConfirmation => isZh ? '\u7b49\u5f85\u4f60\u7684\u78ba\u8a8d' : 'Waiting for your confirmation';
  String get viewProfile => isZh ? '\u67e5\u770b\u6a94\u6848' : 'View profile';
  String get chooseFriendShip => isZh ? '\u9078\u64c7\u8981\u9760\u8fd1\u7684\u597d\u53cb\u98db\u8239' : 'Choose a friend ship';
  String get cancel => isZh ? '\u53d6\u6d88' : 'Cancel';
  String get addFormation => isZh ? '\u65b0\u589e\u7de8\u968a' : 'Add formation';
  String get formationHint => isZh ? '\u904b\u52d5 / \u7814\u7a76 / \u8a2d\u8a08...' : 'Sport / Research / Design...';
  String get allTabs => isZh ? '\u5168\u90e8' : 'All';
  String get linkStatus => isZh ? '\u9023\u7d50\u72c0\u614b' : 'Link status';
  String get sendSoftPing => isZh ? '\u9001\u51fa\u8f15\u8a0a\u865f' : 'Send soft ping';
  String get logSharedMoment => isZh ? '\u8a18\u9304\u5171\u540c\u7247\u6bb5' : 'Log shared moment';
  String get openBaseWorkbench => isZh ? '\u524d\u5f80\u57fa\u5730' : 'Open Base';
  String get openCapsuleArchive => isZh ? '\u524d\u5f80\u81a0\u56ca' : 'Open Capsule';
  String get orbitContactLayer => isZh ? '\u8ecc\u9053\u4e92\u52d5\u5c64' : 'Orbit contact layer';
  String get recentUpdate => isZh ? '\u6700\u8fd1\u66f4\u65b0' : 'Recent update';
  String get noFriendSelected => isZh ? '\u5c1a\u672a\u9078\u64c7\u597d\u53cb\u98db\u8239' : 'No friend ship selected';
  String get selectShipHint => isZh
      ? '\u9ede\u4e00\u4e0b\u98db\u8239\uff0c\u958b\u555f\u95dc\u4fc2\u4e92\u52d5\u5c64\u4e26\u57f7\u884c\u4e0b\u4e00\u6b65\u3002'
      : 'Tap a ship to open the relationship layer and take the next step.';
  String get memoryLogged => isZh ? '\u56de\u61b6\u5df2\u5beb\u5165\u81a0\u56ca\u8259' : 'Memory logged to Capsule';
  String get signalSent => isZh ? '\u8a0a\u865f\u5df2\u56de\u5beb\u57fa\u5730\u8259' : 'Signal sent to Base';
  String get focusFriend => isZh ? '\u7126\u9ede\u597d\u53cb' : 'Focus friend';
  String get jumpToFriend => isZh ? '\u8e8d\u9077\u5230\u597d\u53cb\u9644\u8fd1' : 'Jump near friend';
}

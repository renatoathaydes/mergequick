import 'dart:html';

import 'package:flattery/flattery_widgets.dart';

import '../repositories.dart';

class RepoListView extends Container<RepoView> {}

class RepoView extends Repo with Widget, ShadowWidget {
  RepoView(Repo repo) : super.copy(repo);

  @override
  String get stylesheet => '''
  * { color: blue; }
  ''';

  @override
  Element build() => Grid(columnGap: '1em', children: [
        [Text(username), Text(project), Text(repoType.toString())]
      ]).root;
}

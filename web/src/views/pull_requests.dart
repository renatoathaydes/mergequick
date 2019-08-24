import 'dart:collection';
import 'dart:html';

import 'package:flattery/flattery.dart';
import 'package:flattery/flattery_widgets.dart';

import '../pull_requests.dart';
import '../repositories.dart';

class PullRequestsView with Widget, ShadowWidget {
  final UnmodifiableListView<Repo> _repos;

  PullRequestsView(this._repos);

  @override
  Element build() {
    return Container(
            children: _repos
                .expand((repo) => repo.pullRequests)
                .map((pr) => PrView(pr))
                .toList(growable: false))
        .root;
  }
}

class PrView extends PullRequest with Widget, ShadowWidget {
  final Widget _title;
  final Widget _reviewersView;

  PrView(PullRequest pr)
      : _title = widget(SpanElement()
          ..id = 'title'
          ..append(AnchorElement()
            ..href = pr.link
            ..text = pr.id)
          ..appendText(pr.title)),
        _reviewersView = _ReviewersView(pr.reviewers),
        super.copy(pr);

  @override
  String get stylesheet => '''
  :host { margin-top: 0.3em; }
  div { background-color: #d1e8f8; }
  a { color: #d1e8f8; margin-right: 1em; }
  #title { padding: 0.5em; font-size: 1.2em; background-color: #0f466b; color: white; }
  ''';

  @override
  Element build() => Grid(rowGap: '0.3em', columnGap: '0.2em', columnWidths: [
        '0.5fr',
        '1fr'
      ], children: [
        [_title, _title], // takes up the 2 columns
        [Text("Author: $author"), Text("Created: $created")],
        [_reviewersView, _reviewersView],
      ]).root;
}

class _ReviewersView with Widget {
  final Element root;

  _ReviewersView(List<Reviewer> reviewers)
      : root = Row(
          allowWrap: true,
          children: reviewers
              .map((r) => widget(
                  ImageElement(src: r.avatarUrl, width: 64, height: 64)
                    ..alt = r.user))
              .toList(growable: false),
        ).root;
}

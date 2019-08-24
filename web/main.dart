import 'dart:collection';
import 'dart:html' hide Text;

import 'package:flattery/flattery_widgets.dart';

import 'src/animation.dart';
import 'src/pull_requests.dart';
import 'src/repositories.dart';
import 'src/views/pull_requests.dart';
import 'src/views/repositories.dart';

Element overlay;

void main() {
  overlay = querySelector('.overlay');
  fadeAway(overlay.style, duration: Duration(milliseconds: 200));
  final root = querySelector('#output');

//  final reviewers = UnmodifiableListView([
//    Reviewer('joe', 'https://github.com/images/error/other_user_happy.gif'),
//  ]);
//  final repo = Repo('renato', 'project', RepoType.github);
//  final prs = [
//    PullRequest('123', 'joe', 'change stuff', DateTime.now(),
//        'https://renato.athaydes.com', reviewers),
//    PullRequest('443', 'mary', 'fix issue 4', DateTime.now(),
//        'https://renato.athaydes.com', reviewers),
//    PullRequest('566', 'bob', 'done something', DateTime.now(),
//        'https://renato.athaydes.com', reviewers),
//  ];
//  cachePullRequests(repo, prs);
//  root.append(PullRequestsView(UnmodifiableListView([
//    repo,
//  ])).root);
   root.append(Splash(showLoadingUntilCompletion(getRepos(), overlay)).root);
}

Widget _spacer({String width = '80%', String height = '0em'}) => Rectangle(
    width: width, height: height, fill: 'transparent', border: 'none');

class Splash with Widget, ShadowWidget {
  bool _loading = true;
  final _user = InputElement();
  final _project = InputElement();
  final _error = Text('', id: 'url-error');
  final _repoView = RepoListView();

  Splash(Future<List<Repo>> repos) {
    _user
      ..onKeyUp.listen(_cleanError)
      ..placeholder = 'User Name';
    _project
      ..onKeyUp.listen(_cleanError)
      ..placeholder = 'Project Name';

    repos.then((repoList) {
      _loading = false;
      _repoView.addAll(repoList.map((r) => RepoView(r)));
      rebuild();
    });
  }

  @override
  String get stylesheet => '''
  * { color: black; }
  button { padding: 1em; font-size: 1.5em; border: none; background-color: springgreen; cursor: pointer; }
  button:hover { background-color: palegreen; }
  input { font-size: 1.6em; margin-top: 0.2em; margin-right: 0.2em; padding: 0.2em; }
  .main-label { font-size: 2em; color: #2a6592; border: solid #2a6592 2px; border-radius: 0.3em; }
  #no-repos-yet { color: darkgray; font-style: italic; font-size: 2em; }
  #url-error { color: red; font-weight: bold; }
  ''';

  void _cleanError([_]) => _error?.text = '';

  void _addRepo(_) async {
    final username = _user?.value?.trim() ?? "";
    final projectName = _project?.value?.trim() ?? "";
    if (username.isEmpty || projectName.isEmpty) {
      _error?.text = 'Please enter a username and project';
    } else {
      final repo = Repo(username, projectName, RepoType.github);
      if (_repoView.contains(repo)) {
        _error.text = 'Repository already exists';
      } else {
        try {
          await showLoadingUntilCompletion(repo.fetchPullRequests(), overlay);
          final mustRebuild = _repoView.isEmpty;
          _repoView.add(RepoView(repo));
          if (mustRebuild) rebuild();
        } on Exception catch (e) {
          _error.text = 'There was an error accessing the repository: $e';
        }
      }
    }
  }

  @override
  Element build() {
    List<ColumnAlignment> childAlignments = _repoView.isEmpty
        ? []
        // PR label, pull requests view, Repositories label
        : [
            ColumnAlignment.stretch,
            ColumnAlignment.stretch,
            ColumnAlignment.stretch
          ];
    return Column(
        defaultAlignment: ColumnAlignment.center,
        childrenAlignments: childAlignments,
        children: [
          if (_repoView.isEmpty)
            Text(
                _loading
                    ? "Loading your repositories"
                    : "You don't have any repositories yet!",
                id: 'no-repos-yet')
          else ...[
            MainLabel('Pull Requests currently open:'),
            PullRequestsView(UnmodifiableListView(_repoView)),
            MainLabel('Your repositories:'),
            _repoView
          ],
          _spacer(height: '4em'),
          Row(
              justify: JustifyContent.spaceBetween,
              allowWrap: true,
              children: [widget(_user), widget(_project)]),
          _error,
          _spacer(height: '1em'),
          widget(ButtonElement()
            ..text = 'Add repository'
            ..onClick.listen(_addRepo)),
        ]).root;
  }
}

class MainLabel extends Text {
  MainLabel(String text, {String id}) : super(text, id: id) {
    root.classes.add('main-label');
  }
}

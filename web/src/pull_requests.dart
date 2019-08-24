import 'dart:collection';

import 'repositories.dart';

class Reviewer {
  String user;
  String avatarUrl;

  Reviewer(this.user, this.avatarUrl);

  Reviewer.fromGitHub(json)
      : this(json['login'] as String, json['avatar_url'] as String);
}

class PullRequest {
  final String id;
  final String author;
  final String title;
  final DateTime created;
  final String link;
  final UnmodifiableListView<Reviewer> reviewers;

  PullRequest(this.id, this.author, this.title, this.created, this.link,
      this.reviewers);

  PullRequest.copy(PullRequest other)
      : this(other.id, other.author, other.title, other.created, other.link,
            other.reviewers);

  PullRequest.fromGithub(pr)
      : this(
            pr['number']?.toString() ?? 'unknown',
            pr['user']['login'] as String,
            pr['title'] as String,
            DateTime.parse(pr['created_at'] as String),
            pr['diff_url'] as String,
            UnmodifiableListView(((pr['requested_reviewers'] ?? []) as List)
                .map((r) => Reviewer.fromGitHub(r))));
}

final _pullRequestsCache = <Repo, List<PullRequest>>{};

List<PullRequest> cachePullRequests(Repo repo, Iterable<PullRequest> prs) {
  _initializeRefreshLoop();
  final prList = prs.toList(growable: false);
  _pullRequestsCache[repo] = prList;
  return prList;
}

List<PullRequest> fromCache(Repo repo) => _pullRequestsCache[repo];

void _initializeRefreshLoop() {
  // monitor PRs every minute or so
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'pull_requests.dart';

typedef PullRequestsGetter = Future<List<PullRequest>> Function(Repo repo);

enum RepoType { github }

@sealed
class Repo {
  final String username;
  final String project;
  final RepoType repoType;
  PullRequestsGetter _prGetter;

  Repo(this.username, this.project, this.repoType)
      : _prGetter = _prGetterFor(repoType);

  Repo.copy(Repo other) : this(other.username, other.project, other.repoType);

  Future<List<PullRequest>> fetchPullRequests() async =>
      cachePullRequests(this, await _prGetter(this));

  List<PullRequest> get pullRequests => fromCache(this) ?? [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Repo &&
          username == other.username &&
          project == other.project &&
          repoType == other.repoType;

  @override
  int get hashCode => username.hashCode ^ project.hashCode ^ repoType.hashCode;
}

Future<List<Repo>> getRepos() async {
  // TODO load repos from storage
  await Future.delayed(Duration(seconds: 2));
  return [];
}

PullRequestsGetter _prGetterFor(RepoType repoType) {
  switch (repoType) {
    case RepoType.github:
      return _githubPrGetter;
    default:
      throw StateError("Unknown RepoType: $repoType");
  }
}

Future<List<PullRequest>> _githubPrGetter(Repo repo) async {
  final url =
      "https://api.github.com/repos/${repo.username}/${repo.project}/pulls?state=open";
  final response = await http
      .get(url, headers: const {'Accept': 'application/vnd.github.v3+json'});
  print("GitHub response: ${response}");
  if (response.statusCode != 200) {
    throw Exception(
        "Unexpected status code: ${response.statusCode} - ${response.body}");
  } else {
    final json = jsonDecode(response.body) as List;
    return json.map((pr) => PullRequest.fromGithub(pr)).toList(growable: false);
  }
}

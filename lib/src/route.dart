final PathMatcher = new RegExp(r"\/(:?[A-z0-9,.\-\+:(\?\+\*\(\))]+)?");
final DateMatcher = new RegExp(
    r"^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?$",
    caseSensitive: false);

class Route implements Comparable<Route> {
  RegExp _pathMatcher = null;
  List<String> _params = [];

  Route(Pattern path) {
    if (path is String) {
      String sPath = path;
      if (sPath.endsWith("/")) path = sPath.substring(0, sPath.length - 1);
      if (_fullMatch(PathMatcher, sPath)) {
        String pattern = r"";
        for (Match match in PathMatcher.allMatches(sPath)) {
          if (match.groupCount > 0 && match[1] != null) {
            if (match[1].startsWith(":")) {
              pattern += r"\/([A-z0-9,.\-\+:]+)";
              this._params.add(match[1].substring(1));
            } else
              pattern += "\/" + match[1];
          }
        }
        this._pathMatcher = new RegExp(pattern + r"/?");
      } else {
        throw new FormatException("The route is not a correct path string");
      }
    } else if (path is RegExp) {
      String pattern = path.pattern;
      if (pattern.startsWith("^")) pattern = pattern.substring(1);
      if (pattern.endsWith("\$"))
        pattern = pattern.substring(0, pattern.length - 1);
      this._pathMatcher = new RegExp(pattern,
          multiLine: false, caseSensitive: path.isCaseSensitive);
    } else
      throw new FormatException("A path must be a valid string or Regexp");
  }

  static bool _fullMatch(RegExp exp, String path) {
    return new RegExp("^(${exp.pattern})+\$").hasMatch(path);
  }

  bool match(String path) => _fullMatch(this._pathMatcher, path);

  String _matchPath(String path) {
    if (!path.endsWith("/")) path += "/";
    String subPath = this._pathMatcher.stringMatch(path);
    if (subPath != null && !subPath.endsWith("/")) subPath += "/";
    return subPath;
  }

  String subPath(String path) {
    if (isSubPath(path))
      return "/" + path.substring(this._matchPath(path).length);
    else
      throw new Exception("The path ${path} don't have a subpath of ${this}.");
  }

  bool isSubPath(String path){
    String matchPath = this._matchPath(path);
    if (matchPath == null) return false;
    else return path.startsWith(matchPath);
  }

  Map<String, Object> parameters(String path) {
    Map<String, Object> toret = {};

    if (this._params.length > 0) {
      List<String> params = new List.from(this._params);

      for (Match match in this._pathMatcher.allMatches(path)) {
        for (int i = 1; i <= match.groupCount; i++) {
          toret[params.removeAt(0)] = _parseParam(match[i]);
        }
      }
    }

    return toret;
  }

  static Object _parseParam(String param) {
    if (param.isEmpty)
      return null;
    else if (param == "true")
      return true;
    else if (param == "false")
      return false;
    else if (!num.parse(param, (_) => double.NAN).isNaN) {
      try {
        return int.parse(param);
      } catch (_) {
        return double.parse(param);
      }
    } else if (param.contains(","))
      return param.split(",").map(_parseParam).toList();
    else if (DateMatcher.hasMatch(param))
      return DateTime.parse(param);
    else
      return param;
  }

  @override
  int compareTo(Route other) =>
      this._pathMatcher.pattern.compareTo(other._pathMatcher.pattern);

  @override
  String toString() => this._pathMatcher.pattern;
}

class ToManyCommand {
  static List<dynamic> create (Map<String, dynamic> data) =>
      [0,0,data];

  static List<dynamic> update(int id, Map<String, dynamic> data) =>
      [1,id, data];

  static List<dynamic> delete(int id) =>
      [2,id];

  static List<dynamic> unlink(int id) =>
      [3,id];

  static List<dynamic> link(int id) =>
      [4, id];

  static List<dynamic> unlinkAll() => [5];

  static List<dynamic> replaceAll(List<int> ids) =>
      [6,0, ids];
}

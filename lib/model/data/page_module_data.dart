enum PageType {
  WEATHER, // 天气页面
  GIFT, // 福利页面
  READ, // 闲读页面
  GANHUO, // 干货页面
  COLLECT, // 收藏页面
}

class PageModule {
  PageType page = PageType.WEATHER;
  bool open = true;

  PageModule({required this.page, required this.open});

  PageModule.fromJson(Map<String, dynamic> json) {
    switch (json["page"]) {
      case "weather":
        page = PageType.WEATHER;
        break;
      case "gift":
        page = PageType.GIFT;
        break;
      case "read":
        page = PageType.READ;
        break;
      case "ganhuo":
        page = PageType.GANHUO;
        break;
      case "collect":
        page = PageType.COLLECT;
        break;
    }
    open = json["open"] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    switch (page) {
      case PageType.WEATHER:
        data["page"] = "weather";
        break;
      case PageType.GIFT:
        data["page"] = "gift";
        break;
      case PageType.READ:
        data["page"] = "read";
        break;
      case PageType.GANHUO:
        data["page"] = "ganhuo";
        break;
      case PageType.COLLECT:
        data["page"] = "collect";
        break;
    }
    data["open"] = this.open;
    return data;
  }

  @override
  String toString() {
    return "PageModule {page: $page, open: $open}";
  }
}

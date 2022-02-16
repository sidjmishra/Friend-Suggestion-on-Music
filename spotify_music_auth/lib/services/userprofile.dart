class UserProfile {
  String? _country;
  String? _displayName;
  String? _email;
  ExplicitContent? _explicitContent;
  ExternalUrls? _externalUrls;
  Followers? _followers;
  String? _href;
  String? _id;
  List<Images>? _images;
  String? _product;
  String? _type;
  String? _uri;

  UserProfile(
      {country,
      displayName,
      email,
      explicitContent,
      externalUrls,
      followers,
      href,
      id,
      images,
      product,
      type,
      uri}) {
    if (country != null) {
      _country = country;
    }
    if (displayName != null) {
      _displayName = displayName;
    }
    if (email != null) {
      _email = email;
    }
    if (explicitContent != null) {
      _explicitContent = explicitContent;
    }
    if (externalUrls != null) {
      _externalUrls = externalUrls;
    }
    if (followers != null) {
      _followers = followers;
    }
    if (href != null) {
      _href = href;
    }
    if (id != null) {
      _id = id;
    }
    if (images != null) {
      _images = images;
    }
    if (product != null) {
      _product = product;
    }
    if (type != null) {
      _type = type;
    }
    if (uri != null) {
      _uri = uri;
    }
  }

  String? get country => _country;
  set country(String? country) => _country = country;
  String? get displayName => _displayName;
  set displayName(String? displayName) => _displayName = displayName;
  String? get email => _email;
  set email(String? email) => _email = email;
  ExplicitContent? get explicitContent => _explicitContent;
  set explicitContent(ExplicitContent? explicitContent) =>
      _explicitContent = explicitContent;
  ExternalUrls? get externalUrls => _externalUrls;
  set externalUrls(ExternalUrls? externalUrls) => _externalUrls = externalUrls;
  Followers? get followers => _followers;
  set followers(Followers? followers) => _followers = followers;
  String? get href => _href;
  set href(String? href) => _href = href;
  String? get id => _id;
  set id(String? id) => _id = id;
  List<Images>? get images => _images;
  set images(List<Images>? images) => _images = images;
  String? get product => _product;
  set product(String? product) => _product = product;
  String? get type => _type;
  set type(String? type) => _type = type;
  String? get uri => _uri;
  set uri(String? uri) => _uri = uri;

  UserProfile.fromJson(Map<String, dynamic> json) {
    _country = json['country'];
    _displayName = json['display_name'];
    _email = json['email'];
    _explicitContent = json['explicit_content'] != null
        ? new ExplicitContent.fromJson(json['explicit_content'])
        : null;
    _externalUrls = json['external_urls'] != null
        ? new ExternalUrls.fromJson(json['external_urls'])
        : null;
    _followers = json['followers'] != null
        ? new Followers.fromJson(json['followers'])
        : null;
    _href = json['href'];
    _id = json['id'];
    if (json['images'] != null) {
      _images = <Images>[];
      json['images'].forEach((v) {
        _images!.add(new Images.fromJson(v));
      });
    }
    _product = json['product'];
    _type = json['type'];
    _uri = json['uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = _country;
    data['display_name'] = _displayName;
    data['email'] = _email;
    if (_explicitContent != null) {
      data['explicit_content'] = _explicitContent!.toJson();
    }
    if (_externalUrls != null) {
      data['external_urls'] = _externalUrls!.toJson();
    }
    if (_followers != null) {
      data['followers'] = _followers!.toJson();
    }
    data['href'] = _href;
    data['id'] = _id;
    if (_images != null) {
      data['images'] = _images!.map((v) => v.toJson()).toList();
    }
    data['product'] = _product;
    data['type'] = _type;
    data['uri'] = _uri;
    return data;
  }
}

class ExplicitContent {
  bool? _filterEnabled;
  bool? _filterLocked;

  ExplicitContent({filterEnabled, filterLocked}) {
    if (filterEnabled != null) {
      _filterEnabled = filterEnabled;
    }
    if (filterLocked != null) {
      _filterLocked = filterLocked;
    }
  }

  bool? get filterEnabled => _filterEnabled;
  set filterEnabled(bool? filterEnabled) => _filterEnabled = filterEnabled;
  bool? get filterLocked => _filterLocked;
  set filterLocked(bool? filterLocked) => _filterLocked = filterLocked;

  ExplicitContent.fromJson(Map<String, dynamic> json) {
    _filterEnabled = json['filter_enabled'];
    _filterLocked = json['filter_locked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter_enabled'] = _filterEnabled;
    data['filter_locked'] = _filterLocked;
    return data;
  }
}

class ExternalUrls {
  String? _spotify;

  ExternalUrls({spotify}) {
    if (spotify != null) {
      _spotify = spotify;
    }
  }

  String? get spotify => _spotify;
  set spotify(String? spotify) => _spotify = spotify;

  ExternalUrls.fromJson(Map<String, dynamic> json) {
    _spotify = json['spotify'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['spotify'] = _spotify;
    return data;
  }
}

class Followers {
  String? _href;
  int? _total;

  Followers({href, total}) {
    if (href != null) {
      _href = href;
    }
    if (total != null) {
      _total = total;
    }
  }

  String? get href => _href;
  set href(String? href) => _href = href;
  int? get total => _total;
  set total(int? total) => _total = total;

  Followers.fromJson(Map<String, dynamic> json) {
    _href = json['href'];
    _total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = _href;
    data['total'] = _total;
    return data;
  }
}

class Images {
  String? _height;
  String? _url;
  String? _width;

  Images({height, url, width}) {
    if (height != null) {
      _height = height;
    }
    if (url != null) {
      _url = url;
    }
    if (width != null) {
      _width = width;
    }
  }

  String? get height {
    return _height;
  }

  set height(String? height) => _height = height;
  String? get url {
    return _url;
  }

  set url(String? url) => _url = url;
  String? get width {
    return _width;
  }

  set width(String? width) => _width = width;

  Images.fromJson(Map<String, dynamic> json) {
    _height = json['height'];
    _url = json['url'];
    _width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = _height;
    data['url'] = _url;
    data['width'] = _width;
    return data;
  }
}

import 'dart:convert';

class Configuration {
    Config? config;

    Configuration({
        this.config,
    });

    factory Configuration.fromJson(String str) => Configuration.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Configuration.fromMap(Map<String, dynamic> json) => Configuration(
        config: json["config"] == null ? null : Config.fromMap(json["config"]),
    );

    Map<String, dynamic> toMap() => {
        "config": config?.toMap(),
    };
}

class Config {
    Mode? dark;
    Mode? light;
    Logos? logos;

    Config({
        this.dark,
        this.light,
        this.logos,
    });

    factory Config.fromJson(String str) => Config.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Config.fromMap(Map<String, dynamic> json) => Config(
        dark: json["dark"] == null ? null : Mode.fromMap(json["dark"]),
        light: json["light"] == null ? null : Mode.fromMap(json["light"]),
        logos: json["logos"] == null ? null : Logos.fromMap(json["logos"]),
    );

    Map<String, dynamic> toMap() => {
        "dark": dark?.toMap(),
        "light": light?.toMap(),
        "logos": logos?.toMap(),
    };
}

class Mode {
    String? hintText;
    String? alternate;
    String? primaryText;
    String? primaryColor;
    String? tertiaryText;
    String? secondaryText;
    String? tertiaryColor;
    String? secondaryColor;
    String? primaryBackground;
    String? tertiaryBackground;
    String? secondaryBackground;

    Mode({
        this.hintText,
        this.alternate,
        this.primaryText,
        this.primaryColor,
        this.tertiaryText,
        this.secondaryText,
        this.tertiaryColor,
        this.secondaryColor,
        this.primaryBackground,
        this.tertiaryBackground,
        this.secondaryBackground,
    });

    factory Mode.fromJson(String str) => Mode.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Mode.fromMap(Map<String, dynamic> json) => Mode(
        hintText: json["hintText"],
        alternate: json["alternate"],
        primaryText: json["primaryText"],
        primaryColor: json["primaryColor"],
        tertiaryText: json["tertiaryText"],
        secondaryText: json["secondaryText"],
        tertiaryColor: json["tertiaryColor"],
        secondaryColor: json["secondaryColor"],
        primaryBackground: json["primaryBackground"],
        tertiaryBackground: json["tertiaryBackground"],
        secondaryBackground: json["secondaryBackground"],
    );

    Map<String, dynamic> toMap() => {
        "hintText": hintText,
        "alternate": alternate,
        "primaryText": primaryText,
        "primaryColor": primaryColor,
        "tertiaryText": tertiaryText,
        "secondaryText": secondaryText,
        "tertiaryColor": tertiaryColor,
        "secondaryColor": secondaryColor,
        "primaryBackground": primaryBackground,
        "tertiaryBackground": tertiaryBackground,
        "secondaryBackground": secondaryBackground,
    };
}

class Logos {
    String? logoColor;
    String? logoBlanco;

    Logos({
        this.logoColor,
        this.logoBlanco,
    });

    factory Logos.fromJson(String str) => Logos.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Logos.fromMap(Map<String, dynamic> json) => Logos(
        logoColor: json["logoColor"],
        logoBlanco: json["logoBlanco"],
    );

    Map<String, dynamic> toMap() => {
        "logoColor": logoColor,
        "logoBlanco": logoBlanco,
    };
}

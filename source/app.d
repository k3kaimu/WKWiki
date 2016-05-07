module app;

import vibe.d;
import api;
import fileio;


shared static this()
{
    import std.file: readText;

    auto rawFileSettings = new HTTPFileServerSettings();
    rawFileSettings.maxAge = 1.seconds;
    rawFileSettings.serverPathPrefix = "/raw";

    auto pubFileSettings = new HTTPFileServerSettings();
    pubFileSettings.maxAge = 1.seconds;

    auto router = new URLRouter;
    router
    .registerRestInterface(new ServerAPI!VibedFileIO("./public", "./raw"), "/api")
    .get("/raw/*", serveStaticFiles("./raw", rawFileSettings))
    .get("*", serveStaticFiles("./public", pubFileSettings));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    listenHTTP(settings, router);
}

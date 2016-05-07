module api;


import std.base64;
import std.file;
import std.json;
import std.path;

import vibe.d;

import fileio;

struct Document
{
    string document;            // markdown
    string[] attachmentList;    // 添付ファイル名
}


interface IServerAPI
{
    @method(HTTPMethod.GET)
    @path("document.json")
    Document getDocument(string path);

    @method(HTTPMethod.POST)
    @path("document.json")
    bool addDocument(string path, string document);

    @method(HTTPMethod.DELETE)
    @path("document.json")
    bool deleteDocument(string path);

    @method(HTTPMethod.GET)
    @path("attachment.json")
    string getAttachment(string path, string name);

    @method(HTTPMethod.POST)
    @path("attachment.json")
    bool addAttachment(string path, string name, string content);

    @method(HTTPMethod.DELETE)
    @path("attachment.json")
    bool deleteAttachment(string path, string name);
}

import std.stdio;

class ServerAPI(alias IO) : IServerAPI
{
    this(string docRootDir, string attachRootDir)
    {
        _docRootDir = docRootDir;
        _attachRootDir = attachRootDir;
    }


    string getMDFilePath(string path)
    {
        if(path.front == '/') path = path[1 .. $];
        return buildPath(_docRootDir, path.setExtension(".md"));
    }


    string getAttachDir(string path)
    {
        if(path.front == '/') path = path[1 .. $];
        return buildPath(_attachRootDir, path.stripExtension());
    }


    Document getDocument(string path)
    {
        Document ret;

        // htmlファイルのURLからMarkdownのパスに変換し，UTF8でファイルを読み込む
        ret.document = IO.readText(getMDFilePath(path));

        // htmlファイルのURLから，添付ファイルが入っているディレクトリに変換する
        auto attachDir = getAttachDir(path);

        // 添付ファイルのディレクトリを走査する
        if(IO.exists(attachDir)){
            foreach(de; IO.dirEntries(attachDir, SpanMode.shallow)) {
                if(de.isDir) continue;

                ret.attachmentList ~= de.name.baseName;
            }
        }

        return ret;
    }


    bool addDocument(string path, string document)
    {
        auto mdFilePath = getMDFilePath(path);
        auto attachDir = getAttachDir(path);

        import std.stdio;

        IO.mkdirRecurse(mdFilePath.dirName);
        IO.mkdirRecurse(attachDir);

        // Markdownファイルを保存する
        IO.writeText(mdFilePath, document);

        return true;
    }


    bool deleteDocument(string path)
    {
        auto mdFilePath = getMDFilePath(path);
        if(!IO.exists(mdFilePath) || path.extension != ".md") return false;

        // Markdownファイルを削除する
        IO.remove(mdFilePath);

        return true;
    }


    string getAttachment(string path, string name)
    {
        auto attachDir = getAttachDir(path);
        auto attachPath = buildPath(attachDir, name.baseName);

        if(!IO.exists(attachPath)) return "";

        void[] buf = IO.read(attachPath);
        return Base64.encode(cast(ubyte[])buf);
    }


    bool addAttachment(string path, string name, string content)
    {
        auto attachDir = getAttachDir(path);
        auto attachPath = buildPath(attachDir, name.baseName);

        IO.mkdirRecurse(attachDir);

        IO.write(attachPath, Base64.decode(content));

        return true;
    }


    bool deleteAttachment(string path, string name)
    {
        auto attachDir = getAttachDir(path);
        auto attachPath = buildPath(attachDir, name.baseName);

        if(!IO.exists(attachPath)) return false;

        IO.remove(attachPath);

        return true;
    }


  private:
    string _docRootDir;
    string _attachRootDir;
}

unittest
{
    import std.file;
    scope(exit) rmdirRecurse("./test-tmp");

    immutable docDir = "./test-tmp/doc";
    immutable rawDir = "./test-tmp/raw";

    auto api = new ServerAPI!(PhobosFileIO)(docDir, rawDir);

    api.addDocument("/wiki/foo.html", "abcd");
    assert(exists("./test-tmp/doc/wiki/foo.md"));
    assert(readText("./test-tmp/doc/wiki/foo.md") == "abcd");

    api.addAttachment("/wiki/foo.html", "attach1.txt", Base64.encode(cast(ubyte[])"1234567890"));
    assert(exists("./test-tmp/raw/wiki/foo/attach1.txt"));
    assert(readText("./test-tmp/raw/wiki/foo/attach1.txt") == "1234567890");

    auto getDocRes = api.getDocument("/wiki/foo.html");
    assert(getDocRes.document == "abcd");
    assert(getDocRes.attachmentList == ["attach1.txt"]);

    auto getAttRes = api.getAttachment("/wiki/foo.html", "attach1.txt");
    assert(Base64.decode(getAttRes) == "1234567890");

    api.deleteAttachment("/wiki/foo.html", "attach1.txt");
    assert(!exists("./test-tmp/raw/wiki/foo/attach1.txt"));

    getDocRes = api.getDocument("/wiki/foo.html");
    assert(getDocRes.document == "abcd");
    assert(getDocRes.attachmentList.empty);

    api.deleteDocument("/wiki/foo.html");
    assert(!exists("./test-tmp/doc/wiki/foo.html"));
}

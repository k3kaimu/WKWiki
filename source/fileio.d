module fileio;


enum bool isFileIO(alias IO) = is(typeof((){
    void[] buf;
    bool b;
    string str;

    IO.write("name", buf);
    buf = IO.read("name");

    IO.writeText("name", "filecontent");
    str = IO.readText("name");

    IO.append("name", buf);
    IO.copy("from", "to");
    IO.remove("name");
    IO.rename("from", "to");
    b = IO.exists("file/or/directory");
    b = IO.isDir("file/or/directory");
    b = IO.isSymlink("file/or/directory");

    foreach(de; IO.dirEntries("name")){
        if(de.isDir || de.isSymlink)
            str = de.name;
    }

    IO.mkdir("directory");
    IO.mkdirRecurse("dir/ec/to/ry");
    IO.rmdir("directory");
    IO.rmdirRecurse("dir/ec/to/ry");
}));



alias PhobosFileIO = PhobosFileIO_!();

template PhobosFileIO_()
{
    import std.stdio;

    alias write = std.file.write;
    alias read = std.file.read;
    alias writeText = std.file.write;
    alias readText = std.file.readText;
    alias append = std.file.append;
    alias copy = std.file.copy;
    alias remove = std.file.remove;
    alias rename = std.file.rename;
    alias exists = std.file.exists;
    alias isDir = std.file.isDir;
    alias isSymlink = std.file.isSymlink;
    alias dirEntries = std.file.dirEntries;
    alias mkdir = std.file.mkdir;
    alias mkdirRecurse = std.file.mkdirRecurse;
    alias rmdir = std.file.rmdir;
    alias rmdirRecurse = std.file.rmdirRecurse;
}



alias VibedFileIO = VibedFileIO_!();

template VibedFileIO_()
{
    import vibe.core.file;
    import std.file;

    alias write = vibe.core.file.writeFile;
    alias read = vibe.core.file.readFile;

    void writeText(string path, string content)
    {
        vibe.core.file.writeFileUTF8(vibe.inet.path.Path(path), content);
    }

    alias readText = vibe.core.file.readFileUTF8;
    alias append = vibe.core.file.appendToFile;
    alias copy = vibe.core.file.copyFile;
    alias remove = std.file.remove;
    alias rename = std.file.rename;
    alias exists = std.file.exists;
    alias isDir = std.file.isDir;
    alias isSymlink = std.file.isSymlink;
    alias dirEntries = std.file.dirEntries;
    alias mkdir = std.file.mkdir;
    alias mkdirRecurse = std.file.mkdirRecurse;
    alias rmdir = std.file.rmdir;
    alias rmdirRecurse = std.file.rmdirRecurse;
}
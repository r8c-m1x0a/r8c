* R8C M1x0A用のスタートアップ、ベクターテーブル

[R8C](https://github.com/hirakuni45/R8C) で公開されている以下のファイルを借用しています。

    init.c
    init.h
    start.s
    vect.c
    vect.h

以下のファイルには一部変更をしており、I/Oに直接アクセスできるようになっています。

    m120an.ld

I/Oにビットフィールドで直接アクセス可能なライブラリは [R8C io](https://github.com/r8c-m1x0a/io) で公開しています。

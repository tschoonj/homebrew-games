class Freeciv < Formula
  desc "A Free and Open Source empire-building strategy game"
  homepage "http://freeciv.wikia.com"
  url "https://downloads.sourceforge.net/project/freeciv/Freeciv%202.5/2.5.0/freeciv-2.5.0.tar.bz2"
  mirror "http://download.gna.org/freeciv/stable/freeciv-2.5.0.tar.bz2"
  sha256 "bd9f7523ea79b8d2806d0c1844a9f48506ccd18276330580319913c43051210b"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-games"
    revision 1
    sha256 "c34b7a955b1a534a87392202039584965ba7eb4bca197808395a91b485d417b1" => :yosemite
    sha256 "494f799328f7d7a4bc657f19e38c0edef00dcc19cf12e073b9bcf44db786ace2" => :mavericks
    sha256 "f3a1c6f0606dce6b0a2d9bc7c854867c5be127c6a60eea497189d208d816a35e" => :mountain_lion
  end

  head do
    url "svn://svn.gna.org/svn/freeciv/trunk"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  option "without-nls", "Disable NLS support"
  option "without-sdl", "Disable the SDL Freeciv client"

  depends_on "gettext" if build.with? "nls"
  depends_on "icu4c"
  depends_on "pkg-config" => :build
  depends_on "readline"

  depends_on "sdl" => :recommended
  if build.with? "sdl"
    depends_on "freetype"
    depends_on "sdl_image"
    depends_on "sdl_gfx"
    depends_on "sdl_mixer"
    depends_on "sdl_ttf"
  end

  depends_on "gtk+3" => :recommended

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
    ]

    if build.without? "nls"
      args << "--disable-nls"
    else
      gettext = Formula["gettext"]
      args << "CFLAGS=-I#{gettext.include}"
      args << "LDFLAGS=-L#{gettext.lib}"
    end

    if build.head?
      inreplace "./autogen.sh", "libtoolize", "glibtoolize"
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end

    system "make", "install"
  end

  test do
    system bin/"freeciv-manual"
    File.exist? testpath/"manual6.html"

    server = fork do
      system bin/"freeciv-server", "-l", testpath/"test.log"
    end
    sleep 5
    Process.kill("TERM", server)
    File.exist? testpath/"test.log"
  end
end

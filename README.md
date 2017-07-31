# swift-tcl-demo
Swift executable combining Tcl and Swift

### Building and Installing
This program uses several Swift modules as supporting libraries.
These need to be compiled and linked into shared libraries.
Then, the libraries need to be installed into platform specific locations on the clang compilers linker path.

#### C helpers in libtclrefcount8.6.a
This only installs a static library. The Tcl bindings are really compiled by the modules using the library.
```
git clone swift-tcl8.6
make install
```

#### Swift module SwiftTcl libSwiftTcl.so
This will install libSwiftTcl.so.  If your platform is not supported, then
copy the libSwiftTcl.so to the required directory.  Run ldconfig on Linux machines.
```
git clone swift-tcl
make install
```

#### Swift application SwiftTclDemo
This will run the demo program as a test.
```
git clone swift-tcl-demo
make test
```

#### All-in-one download and builds
Download all the of repositories
```
git clone https://github.com/flightaware/swift-tcl8.6.git
git clone https://github.com/flightaware/swift-tcl.git
git clone https://github.com/flightaware/swift-tcl-demo.git
git clone https://github.com/flightaware/swift-tcl-extension-demo.git
```
Build/Install or Build/Test
```
make -C swift-tcl8.6 install
make -C swift-tcl install
make -C swift-tcl-demo test
make -C swift-tcl-extension-demo test
```

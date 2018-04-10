# Live Broadcaster
Live Streaming Software for Mac and Windows built on Adobe AIR

[![Live Streaming Software](https://app.h7.org/cameleon/image/software/open-source_live-streaming-software.jpg "Live Broadcaster Software")](https://youtube.com/watch?v=tO3nz-MJ970)

### How to Use? ###

- see [Live Streaming with Cameleon Live Broadcaster](https://youtube.com/watch?v=tO3nz-MJ970) (YouTube video)

### How to Debug? ###
- Get [Adobe Flash Builder](https://helpx.adobe.com/creative-cloud/kb/creative-cloud-apps-download.html)
- Install Java SE 6 for [Mac](https://support.apple.com/kb/DL1572?locale=en_US) or Windows
- Download [Apache Flex SDK installer](http://flex.apache.org/installer.html), install Apache Flex SDK 4.16.1 with AIR 28 and set it as default SDK in Flash Builder
- Clone or download project from https://github.com/H7ORG/Live-Broadcaster.git
- Import project to Flash Builder
- Edit `API.properties`. You can skip this but app won't fully work until you get your own google client id and secret for Youtube and Facebook app id for Facebook broadcasting
- Select LiveBroadcaster.mxml in Flash Builder and try to Run or Debug as Desktop Application

### How to make Release? ###
- First test if you can debug from Flash Builder
- Install Ant if you don't have it
- Edit build.properties and add path to Windows or Mac Flex SDK (you should already have it after succesfull debug)
- (Mac Only) Download and install Packager: http://s.sudre.free.fr/Software/Packages/about.html
- Create or get your .p12 certificate and put it to builds/cert/ folder
- Edit live_broadcaster/build.xml lines:
```xml
<property name="KEYSTORE" value="../builds/cert/Certificate.p12"/>
<property name="STOREPASS" value="CERTIFICATE_PASSWORD_HERE"/>
```
- Run `ant build` from live_broadcaster folder
- This should be enought to build unsigned *.pkg or *.exe installers

### How to make signed installer? ###
- You need a certificate in keychain for Mac OS or *.pfx file for Windows
- (Mac Only) get certificate full name from keychain and update build.xml:
```xml
<target name="signpackage.mac" if="${MAC}">
  <exec executable="${PRODUCTSIGN}" failonerror="true">
    <arg value="--sign"/>
    <arg value="FULL CERTIFICATE NAME WITH (ABCDE12345)"/>
    <arg value="${TEMPPKG}"/>
    <arg value="${FINALPKG}"/>
  </exec>
  <delete file="${TEMPPKG}" />
</target>
```
- (Windows only) put *.pfx file to builds/cert/ folder and update build.xml with path and password:
```xml
<target name="package.win" if="${WINDOWS}">
  <echo message="Signing package for Windows" />
  <exec executable="${basedir}/${ISCC}">
    <arg value="/smysigntool=${basedir}\..\builds\tools\iscc\signtool.exe sign /f ${basedir}\..\builds\cert\Certificate.pfx /p PFX_PASSWORD_HERE $f"/>
    <arg value="${basedir}\..\builds\LiveBroadcaster.iss"/>
  </exec>
</target>
```
- (Windows only) Remove ; from ;SignTool=mysigntool in build/LiveBroadcaster.iss
- Run `ant build` from live_broadcaster folder

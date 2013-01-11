require 'formula'

class Cassandra10 < Formula
  url 'http://www.motorlogy.com/apache/cassandra/1.0.12/apache-cassandra-1.0.12-bin.tar.gz'
  homepage 'http://cassandra.apache.org'
  sha1 '2b9ec3e78ca7b64cace82cfbb50492c82794b2cb'

  def install
    (var+"lib/cassandra").mkpath
    (var+"log/cassandra").mkpath
    (etc+"cassandra").mkpath

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/log4j-server.properties", "/var/log/cassandra", "#{var}/log/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"

    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=`dirname $0`/..", "CASSANDRA_HOME=#{prefix}"
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=$CASSANDRA_HOME/conf", "CASSANDRA_CONF=#{etc}/cassandra"
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "$CASSANDRA_HOME/lib/*.jar", "$CASSANDRA_HOME/*.jar"
    end

    rm Dir["bin/*.bat"]

    (etc+"cassandra").install Dir["conf/*"]
    prefix.install Dir["*.txt"] + Dir["{bin,interface,javadoc,lib/licenses}"]
    prefix.install Dir["lib/*.jar"]
  end

  def caveats; <<-EOS.undent
    If this is your first install, automatically load on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{plist_path} ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}
    EOS
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>

        <key>Label</key>
        <string>#{plist_name}</string>

        <key>ProgramArguments</key>
        <array>
            <string>#{opt_prefix}/bin/cassandra</string>
            <string>-f</string>
        </array>

        <key>RunAtLoad</key>
        <true/>

        <key>WorkingDirectory</key>
        <string>#{var}/lib/cassandra</string>
      </dict>
    </plist>
    EOS
  end
end

class Ooniprobe < Formula
  desc "Network interference detection tool"
  homepage "https://ooni.org/"
  url "https://github.com/ooni/probe-cli/archive/v3.9.1.tar.gz"
  sha256 "c49ef4bbad0ce1b41add7af76bbf9345d8a47012314f1635995eea1eb3add139"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "f432bb3e26010db3703eaea0cad45c41637cc78a7a22cf1cc3b98ff3a86ef4c8"
    sha256 cellar: :any_skip_relocation, big_sur:       "77ee0e5ad13b62dcd712d3cd1bb14118edf006010b134127d5808fa093099da3"
    sha256 cellar: :any_skip_relocation, catalina:      "fb647b869612a1d5be97f338a09b66ca86e0b5ab0135abd53d32165b95db20cb"
    sha256 cellar: :any_skip_relocation, mojave:        "3c5178daa5b46e56e25280520030f32f1dbcfdacbf3eda52e57e53e5c229066c"
  end

  depends_on "go" => :build

  def install
    system "go", "run", "./internal/cmd/getresources"
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/ooniprobe"
    (var/"ooniprobe").mkpath
  end

  test do
    (testpath/"config.json").write <<~EOS
      {
        "_version": 3,
        "_informed_consent": true,
        "sharing": {
          "include_ip": false,
          "include_asn": true,
          "upload_results": false
        },
        "nettests": {
          "websites_url_limit": 1,
          "websites_enabled_category_codes": []
        },
        "advanced": {
          "send_crash_reports": true,
          "collect_usage_stats": true
        }
      }
    EOS

    mkdir_p "#{testpath}/ooni_home"
    ENV["OONI_HOME"] = "#{testpath}/ooni_home"
    Open3.popen3(bin/"ooniprobe", "--config", testpath/"config.json", "run", "websites", "--batch") do |_, _, stderr|
      stderr.to_a.each do |line|
        j_line = JSON.parse(line)
        assert_equal j_line["level"], "info"
      end
    end
  end
end

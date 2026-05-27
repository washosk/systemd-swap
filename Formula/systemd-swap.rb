# Homebrew formula for systemd-swap (Linuxbrew only)
#
# ⚠️  IMPORTANT: This formula is for Linuxbrew (Homebrew on Linux) only.
#     macOS does not use systemd and will not benefit from this package.
#
# For Linux users using Homebrew, place this in a Homebrew tap at:
#   https://github.com/YOUR_ORG/homebrew-systemd-swap/blob/main/Formula/systemd-swap.rb
#
# Install with:
#   brew tap YOUR_ORG/systemd-swap
#   brew install systemd-swap
#
# Only works on: Linux (via Linuxbrew), not on macOS

class SystemdSwap < Formula
  desc "Simple swap file manager for systemd (Linux only)"
  homepage "https://github.com/washosk/systemd-swap"
  license "MIT"

  version "1.0.0"

  url "https://github.com/washosk/systemd-swap/releases/download/v#{version}/systemd-swap-#{version}-linux-amd64.tar.gz"
  sha256 "PLACEHOLDER_SHA256_HASH"  # Generate with: shasum -a 256 <downloaded-file>

  # Only for Linux (not macOS — requires systemd)
  depends_on :linux

  def install
    # Install the main script
    bin.install "systemd-swap-#{version}/usr/local/bin/systemd-swap"

    # Install configuration template
    etc.install "systemd-swap-#{version}/etc/systemd/swap.conf" => "systemd-swap.conf"

    # Install systemd service
    mkdir_p prefix/"lib/systemd/system"
    cp "systemd-swap-#{version}/usr/lib/systemd/system/systemd-swap.service",
       prefix/"lib/systemd/system/systemd-swap.service"

    # Install documentation
    doc.install "README.md" if File.exist?("README.md")
  end

  def post_install
    puts "✅ systemd-swap installed!"
    puts ""
    puts "Configuration file: #{etc}/systemd-swap.conf"
    puts "systemd service: #{opt_prefix}/lib/systemd/system/systemd-swap.service"
    puts ""
    puts "To enable and start:"
    puts "  sudo systemctl enable #{opt_prefix}/lib/systemd/system/systemd-swap.service"
    puts "  sudo systemctl start systemd-swap"
    puts ""
    puts "To check status:"
    puts "  sudo systemctl status systemd-swap"
    puts "  swapon --show"
  end

  test do
    assert_predicate bin/"systemd-swap", :exist?
    assert_predicate bin/"systemd-swap", :executable?

    # Basic execution test
    output = shell_output("#{bin}/systemd-swap 2>&1 || true")
    assert_match(/Usage:/, output)
  end
end

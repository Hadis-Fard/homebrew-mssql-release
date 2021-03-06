class MsodbcsqlAT13170 < Formula
  desc "ODBC Driver for Microsoft(R) SQL Server(R)"
  homepage "https://msdn.microsoft.com/en-us/library/mt654048(v=sql.1).aspx"
  url "http://download.microsoft.com/download/4/9/5/495639C0-79E4-45A7-B65A-B264071C3D9A/msodbcsql-13.1.7.0.tar.gz"
  version "13.1.7.0"
  sha256 "2f9dd8f3baeab18539ab35e2ec83a3d87a81a056244408edc242696f3314f566"

  option "without-registration", "Don't register the driver in odbcinst.ini"

  def caveats; <<-EOS.undent
    If you installed this formula with the registration option (default), you'll
    need to manually remove [ODBC Driver 13 for SQL Server] section from
    odbcinst.ini after the formula is uninstalled. This can be done by executing
    the following command:
        odbcinst -u -d -n "ODBC Driver 13 for SQL Server"
    EOS
  end

  keg_only :versioned_formula

  depends_on "unixodbc"
  depends_on "openssl"

  def check_eula_acceptance
    if ENV["ACCEPT_EULA"] != "y" and ENV["ACCEPT_EULA"] != "Y" then
      puts "The license terms for this product can be downloaded from"
      puts "https://aka.ms/odbc131eula and found in"
      puts "/usr/local/share/doc/msodbcsql/LICENSE.txt . By entering 'YES',"
      puts "you indicate that you accept the license terms."
      puts ""
      while true do
        puts "Do you accept the license terms? (Enter YES or NO)"
        accept_eula = STDIN.gets.chomp
        if accept_eula then
          if accept_eula == "YES" then
            break
          elsif accept_eula == "NO" then
            puts "Installation terminated: License terms not accepted."
            return false
          else
            puts "Please enter YES or NO"
          end  
        else
          puts "Installation terminated: Could not prompt for license acceptance."
          puts "If you are performing an unattended installation, you may set"
          puts "ACCEPT_EULA to Y to indicate your acceptance of the license terms."
          return false
        end
      end
    end
    return true
  end

  def install
    if !check_eula_acceptance
      return false
    end

    chmod 0444, "lib/libmsodbcsql.13.dylib"
    chmod 0444, "share/msodbcsql/resources/en_US/msodbcsqlr13.rll"
    chmod 0644, "include/msodbcsql.h"
    chmod 0644, "odbcinst.ini"
    chmod 0644, "share/doc/msodbcsql/LICENSE.txt"

    cp_r ".", "#{prefix}"

    if !build.without? "registration"
        system "odbcinst -u -d -n \"ODBC Driver 13 for SQL Server\""
        system "odbcinst -i -d -f ./odbcinst.ini"
    end
  end
end

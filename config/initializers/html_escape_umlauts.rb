require 'erb'

class ERB
  module Util
    HTML_ESCAPE_UMLAUTS = {
                            'ä' => '&auml;',
                            'Ä' => '&Auml;',
                            'ö' => '&ouml;',
                            'Ö' => '&Ouml;',
                            'ü' => '&uuml;',
                            'Ü' => '&Uuml;',
                            'ß' => '&szlig;',
                            "\r" => '',
                            "\n" => '<br>'
                          }

    def html_escape_umlauts(s)
      s.to_s.gsub(/[äÄöÖüÜß\r\n]/) { |special| HTML_ESCAPE_UMLAUTS[special] }
    end
  end
end

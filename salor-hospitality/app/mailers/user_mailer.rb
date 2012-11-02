class UserMailer < ActionMailer::Base
  default from: "#{SalorHospitality::Application::SH_DEBIAN_SITEID}.sh@localhost"
   
  def plain_message(msg, request, company=nil)
    company ||= @current_company
    @ip = request.remote_ip
    @useragent = request.env['HTTP_USER_AGENT']
    mail(:to => company.email, :subject => "[#{SalorHospitality::Application::SH_DEBIAN_SITEID}.sh] #{ msg }") 
  end
end

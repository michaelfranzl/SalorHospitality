class UserMailer < ActionMailer::Base
  default from: "#{ SalorHospitality::Application::SH_DEBIAN_SITEID }.sh@example.com"
  
  def login_email(company, request)
    @ip = request.remote_ip
    @useragent = request.env['HTTP_USER_AGENT']
    mail(:to => company.email, :subject => "Login to #{ SalorHospitality::Application::SH_DEBIAN_SITEID }.sh") if company.email
  end
end

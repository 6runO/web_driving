require 'csv'
require 'webdrivers'

csv_file_path = Dir['csv_input/*'][0]
file_name = File.basename(csv_file_path)
csv_output_path = "csv_output/output_#{file_name}"

matriculas = []
CSV.foreach(csv_file_path, headers: true, col_sep: ';') do |row|
  matriculas << row[0]
end

puts 'Enter login'
login = gets.chomp
puts 'Enter password'
password = gets.chomp

# options = Selenium::WebDriver::Chrome::Options.new(
options = Selenium::WebDriver::Options.chrome(
  args: ['--headless=new'],
  prefs: {
    download: {
      prompt_for_download: false,
      default_directory: '/home/babs/code/6runO/ufrrj/web_driving/historicos'
    }
  }
)

@driver = Selenium::WebDriver.for :chrome, options: options
options = Selenium::WebDriver::Chrome::Options.new
options.add_option(:detach, true)
@driver.manage.timeouts.implicit_wait = 10

def log_in_sigaa(login, password)
  @driver.get 'https://sigaa.ufrrj.br/sigaa/verTelaLogin.do'
  @driver.find_element(:name, 'user.login').send_keys login
  @driver.find_element(:name, 'user.senha').send_keys password
  @driver.find_element(:css, "input[value='Entrar']").click
end

def navigate_till_historico_form
  @driver.find_element(:id, 'link').click
  @driver.find_element(:link, 'Graduação').click
  @driver.find_element(:link, 'Alunos').click
end

def element_present?(how, what)
  @driver.manage.timeouts.implicit_wait = 2
  result = @driver.find_elements(how, what).size.positive?
  if result
    result = @driver.find_element(how, what).displayed?
  end
  @driver.manage.timeouts.implicit_wait = 10
  result
end

def historicos_by_matricula(matriculas, csv_output_path)
  CSV.open(csv_output_path, 'wb') do |csv|
    csv << ['Matricula', 'Status']
    matriculas.length.times do |i|
      matricula = matriculas[i]
      @driver.find_element(:id, 'formulario:matriculaDiscente').send_keys matricula
      @driver.find_element(:id, 'formulario:buscar').click
      status = 'matrícula não encontrada'
      if element_present?(:id, 'form:selecionarDiscente')
        @driver.find_element(:id, 'form:selecionarDiscente').click
        @driver.find_element(:id, 'btnHistorico').click
        @driver.find_element(:id, 'voltar').click
        status = 'download realizado'
      end
      @driver.find_element(:id, 'formulario:matriculaDiscente').clear
      csv << [matricula, status]
    end
  end
end

begin
  log_in_sigaa(login, password)
  navigate_till_historico_form
  historicos_by_matricula(matriculas, csv_output_path)
  sleep 3
ensure
  @driver.quit
end

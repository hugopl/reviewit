module ErrorsHelper
  def error_message(code)
    case code
    when '404' then 'Sorry, the page you are looking for was not found.'
    else "Congrats, you just found a bug!!\n" \
         'i.e. an internal server error occurred and this is the better output we can give to you.'
    end
  end
end

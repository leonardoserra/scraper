import file_streams/file_stream
import file_streams/file_stream_error
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/io
import gleam/result

pub fn send_request() {
  // Prepare a HTTP request record
  let assert Ok(base_req) = request.to("https://darumabeats404.bandcamp.com/")

  let req =
    request.prepend_header(base_req, "accept", "application/vnd.hmrc.1.0+json")

  // Send the HTTP request to the server
  use resp <- result.try(httpc.send(req))
  io.println(resp.body)

  assert resp.status == 200
  // We get a response record back
  assert create_file("document_fetched.html", resp.body) != Ok(Nil)

  let content_type = response.get_header(resp, "content-type")

  assert content_type == Ok("text/html; charset=UTF-8")

  resp.body
  |> io.println

  // io.println(resp.body)

  Ok(resp)
}

fn create_file(
  filename: String,
  html_doc: String,
) -> Result(Nil, file_stream_error.FileStreamError) {
  let assert Ok(stream) = file_stream.open_write(filename)
  let assert Ok(Nil) = file_stream.write_chars(stream, html_doc)
  let assert Ok(Nil) = file_stream.close(stream)
}

import <%= Slimane %>

func launchApp() throws {
    let app = Slimane()

    app.use(Slimane.Static(root: "\(Process.cwd)/public"))

    app.use { req, next, completion in
        print("[pid:\(Process.pid)]\t\(Time())\t\(req.path ?? "/")")
        next.respond(to: req, result: completion)
    }

    <% if(!fullstack) { %>
    app.get("/") { req, responder in
        responder {
            Response(body: "Welcome to Slimane!")
        }
    }
    <% } else { %>
    app.get("/") { req, responder in
        responder {
            let render = Render(engine: MustacheViewEngine(templateData: ["name": "Slimane"]), path: "index")
            return Response(custom: render)
        }
    }

    // fibonacci with QWFuture and thrush
    app.get("/fibo") { req, responder in
        let promise = Promise<Int> { resolve, reject in
            func fibonacci(_ number: Int) -> (Int) {
                if number <= 1 {
                    return number
                } else {
                    return fibonacci(number - 1) + fibonacci(number - 2)
                }
            }

            let future = QWFuture<Int> { (completion: (() throws -> Int) -> ()) in
                completion {
                    fibonacci(10)
                }
            }

            future.onSuccess { result in
                resolve(result)
            }

            future.onFailure { error in
                reject(error)
            }
        }

        promise
          .then { result in
            responder {
                Response(body: "result is \(result)")
            }
          }
          .failure { error in
              responder {
                  Response(status: .internalServerError, body: "\(error)")
              }
          }
    }
    <% } %>

    print("The server is listening at \(HOST):\(PORT)")
    try app.listen(host: HOST, port: PORT)
}

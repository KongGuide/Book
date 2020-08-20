package kong.training.rest;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.*;

@RestController
@EnableAutoConfiguration
@RequestMapping("log")
public class LogController {

    @RequestMapping(value = "", method = RequestMethod.POST, headers = "Accept=application/json", produces = {
            "application/json" }, consumes = { "application/json" })
    public Boolean log(@RequestBody String log) {
        System.out.println(log);
        return true;
    }

}

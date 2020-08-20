package kong.training.rest;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.*;

@RestController
@EnableAutoConfiguration
@RequestMapping("alert_webhook")
public class AlertingWebHookController {

    @RequestMapping(value = "", method = RequestMethod.POST, headers = "Accept=application/json", produces = {
            "application/json" }, consumes = { "application/json" })
    public Boolean Alert_webhook(@RequestBody String body) {
        System.out.println(body);
        //发起POST请求发送企业微信消息
        // https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=you_token
        return true;
    }

}


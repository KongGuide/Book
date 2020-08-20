package kong.training.rest;

import kong.training.rest.model.LBS;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@EnableAutoConfiguration
@RequestMapping("lbs")
public class LBSController {

    //根据IP地址获取请求的地址位置等信息
    @RequestMapping(value = "", produces = { "application/json" })
    public LBS getLBS(@RequestParam(value = "ip", required = true) String ip) {

        //TODO
        LBS lbs = new LBS();
        lbs.setIp(ip);
        lbs.setISP("中国联通");
        lbs.setLocation("北京市海淀区颐和园路5号北京大学");
        lbs.setLongitude("116.3103998015213");
        lbs.setLatitude("39.99458184558329");
        lbs.setRadius(10);
        lbs.setConfidence(0.2);
        lbs.setCountry("中国");
        lbs.setProvince("北京");
        lbs.setCity("北京");
        lbs.setCode("100091");
        return lbs;
    }

}

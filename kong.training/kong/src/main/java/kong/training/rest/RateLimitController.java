package kong.training.rest;

import kong.training.rest.model.LimitData;
import kong.training.rest.model.RateLimit;
import kong.training.rest.model.RateLimitType;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@EnableAutoConfiguration
@RequestMapping("ratelimit")
public class RateLimitController {

    //http://127.0.0.1:8000/ratelimit?domain=www.kong.com&path=/user&method=GET&companyId=10000
    @RequestMapping(value = "", produces = { "application/json" })
    public LimitData getRateLimit(
            @RequestParam(value = "companyId", required = true) int companyId,
            @RequestParam(value = "path", required = true) String path,
            @RequestParam(value = "method", required = true) String method,
            @RequestParam(value = "domain", required = true) String domain) {
        System.out.println(companyId);
        System.out.println(path);
        System.out.println(method);
        System.out.println(domain);

        //从这里根据条件查询此path接口对应的限频数据，这里数据模拟直接赋值

        LimitData limitData = new LimitData();
        limitData.setTTL(10*60);//10分钟

        RateLimit[] rateLimits= new RateLimit[3];

        RateLimit rateLimit1 = new RateLimit();
        rateLimit1.setSecond(1);
        rateLimit1.setMinute(10);
        rateLimit1.setHour(100);
        rateLimit1.setDay(1000);
        rateLimit1.setType(RateLimitType.Domain_Path_Method_Company);
        rateLimit1.setKey(String.format("%s-%s-%s-%s", domain,path,method,companyId));

        RateLimit rateLimit2 = new RateLimit();
        rateLimit2.setSecond(2);
        rateLimit2.setMinute(20);
        rateLimit2.setHour(200);
        rateLimit2.setDay(2000);
        rateLimit2.setType(RateLimitType.Domain_Company);
        rateLimit2.setKey(String.format("%s-%s", domain,companyId));

        RateLimit rateLimit3 = new RateLimit();
        rateLimit3.setSecond(3);
        rateLimit3.setMinute(30);
        rateLimit3.setHour(300);
        rateLimit3.setDay(3000);
        rateLimit3.setType(RateLimitType.Domain);
        rateLimit3.setKey(domain);

        rateLimits[0] = rateLimit1;
        rateLimits[1] = rateLimit2;
        rateLimits[2] = rateLimit3;

        limitData.setRateLimits(rateLimits);
        return limitData;
    }

}

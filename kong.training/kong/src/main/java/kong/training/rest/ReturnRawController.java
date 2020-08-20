package kong.training.rest;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;


@RestController
@EnableAutoConfiguration
@RequestMapping("return")
public class ReturnRawController {

    //******
    //http://localhost:8000/return/raw
    //返回原始的url和header内容
    @RequestMapping(value = "raw", produces = { "application/json" })
    public String getRaw(HttpServletRequest request) {

        String url = "";
        url = request.getScheme() +"://" + request.getServerName()
                + ":" +request.getServerPort()
                + request.getServletPath();
        if (request.getQueryString() != null){
            url += "?" + request.getQueryString();
        }

        String header = "";
        Enumeration<String> headerNames= request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            header += headerName + " : " + request.getHeader(headerName) + "\n";
        }

        System.out.println(url);
        System.out.println(header);

        return url + "\n" + header;
    }

}

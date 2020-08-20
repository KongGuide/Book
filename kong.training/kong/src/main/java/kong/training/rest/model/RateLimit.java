package kong.training.rest.model;

public class RateLimit {

    //类型id
    //1.接口类型的限制
    //2.站点+企业的限制
    //3.站点的限制
    private RateLimitType type;

    //type类型组合key
    //1.domain+path+method+companyid
    //2.domain+company
    //3.domain
    private String key;

    //每秒限频次数
    private int second;

    //每分钟限频次数
    private int minute;

    //每小时限频次数
    private int hour;

    //每天限频次数
    private int day;

    public RateLimit() {

    }

    public RateLimitType getType() {
        return type;
    }

    public void setType(RateLimitType type) {

        this.type = type;
    }

    public String getKey()
    {
        return key;
    }

    public void setKey(String key)
    {
        this.key = key;
    }

    public int getSecond() {
        return second;
    }

    public void setSecond(int second) {
        this.second = second;
    }

    public int getMinute() {
        return minute;
    }

    public void setMinute(int minute) {
        this.minute = minute;
    }

    public int getHour() {
        return hour;
    }

    public void setHour(int hour) {

        this.hour = hour;
    }

    public int getDay()
    {

        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

}

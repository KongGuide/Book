package kong.training.rest.model;

public class LimitData {

    //每小时限频次数
    private int ttl;

    //每天限频次数
    private RateLimit[] rateLimits;

    public LimitData() {

    }

    public int getTTL() {

        return ttl;
    }

    public void setTTL(int ttl) {

        this.ttl = ttl;
    }

    public RateLimit[] getRateLimits() {
        return rateLimits;
    }

    public void setRateLimits(RateLimit[] rateLimits) {

        this.rateLimits = rateLimits;
    }

}

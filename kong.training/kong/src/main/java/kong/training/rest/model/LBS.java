package kong.training.rest.model;

public class LBS {

    //ip地址
    private String ip;

    //中文地址位置
    private String location;

    //经度
    private String longitude;

    //纬度
    private String latitude;

    //半径
    private double radius;

    //可信度
    private double confidence;

    //网络服务提供商
    private String isp;

    //国家
    private String country;

    //省份
    private String province;

    //城市
    private String city;

    //邮政编码
    private String code;

    public String getIP() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }


    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }


    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }


    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }


    public double getRadius() {
        return radius;
    }

    public void setRadius(double radius) {
        this.radius = radius;
    }


    public double getConfidence() {
        return confidence;
    }

    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }


    public String getISP() {
        return isp;
    }

    public void setISP(String isp) {
        this.isp = isp;
    }


    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }


    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }


    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }


    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }




}

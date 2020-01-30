function fn(period) {
    var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
    var Calendar = Java.type('java.util.Calendar');
    var sdf = new SimpleDateFormat('yyyy-MM-dd');
    var random_one = Math.floor(Math.random() * 10) + 2;
    var random_two = Math.floor(Math.random() * 10) + 12;
    cal = Calendar.getInstance();
    if (period == "tomorrow") {
        cal.add(Calendar.DATE, 1);
    }
    else if (period == "today") {
        cal.add(Calendar.DATE, 0);
    }
    else if (period == "week") {
        cal.add(Calendar.DATE, 7)
    } else if (period == "randDepart") {
        cal.add(Calendar.DATE, random_one)
    } else if (period == "randReturn") {
        cal.add(Calendar.DATE, random_two)
    }
    return sdf.format(cal.getTime());
}
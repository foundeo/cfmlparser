component {

    THIS.UPPER_CASE = true;

    public function forLoop() {
        var a = [1,2,3];
        var b = "";
        for (b in a) {
            return a;
        }
    }

    public function whileLoop() {
        var i = 0;
        
        while (i < 10) {
            i++;
        }
        return i;
    }

}
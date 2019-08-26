package dat;

/**
 * アイテム情報
 */
class ItemDB {
    public static function get(itemID:Int):EscDB.Items {
        for(item in EscDB.items.all) {
            if(itemID == item.value) {
                return item;
            }
        }

        // 見つからなかった
        return null;
    }

    public static function name(itemID:Int):String {
        var item = get(itemID);
        if(item == null) {
            return "";
        }
        return item.name;
    }

}
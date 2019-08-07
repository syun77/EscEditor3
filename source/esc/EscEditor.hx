package esc;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import esc.loader.EscLoader;
import esc.loader.EscObj;
import ui.InfomationUI;
import ui.MovingCursorUI;
import ui.TapUI;

/**
 * 状態
 */
private enum State {
    Execute;    // 実行中
    ScriptWait; // スクリプト終了待ち
    NextScene;  // 次のシーンに進む
}

class EscEditor extends FlxSpriteGroup {
    var _isEdit:Bool = false;
    var _state:State = State.Execute;
    var _loader:EscLoader;
    var _bg:EscSprite;
    var _objs:Array<EscSprite>;
    var _selobj:EscSprite = null;
    var _selframe:FlxSprite = null;
    var _txts:Array<FlxText>;
    var _infomationUI:InfomationUI;
    var _script:EscScript;
    var _movingCursorUI:MovingCursorUI;
    var _tagUI:TapUI;

    /**
     * コンストラクタ
     */
    public function new(root:String, isEdit:Bool) {
        super();

        _isEdit = isEdit;
        _loader = new EscLoader(root);
        _txts = new Array<FlxText>();

        // 背景の読み込み
        {
            var bg = _loader.bg;
            _bg = new EscSprite(bg.x, bg.y, bg);
            bg.setText(_addText());
            this.add(_bg);
        }

        // 選択枠
        _selframe = new FlxSprite(0, 0);
        _selframe.visible = false;
        this.add(_selframe);

        // 配置オブジェクト
        _objs = new Array<EscSprite>();
        for(obj in _loader.objs) {
            var spr = new EscSprite(obj.x, obj.y, obj);
            obj.setText(_addText());
            _objs.push(spr);
        }

        for(obj in _objs) {
            this.add(obj);
        }

        // ヘルプテキスト
        for(txt in _txts) {
            if(isEdit == false) {
                txt.visible = false;
            }
            this.add(txt);
        }


        // 表示オブジェクト更新
        _updateObjVisible();

        // 移動カーソル
        _movingCursorUI = new MovingCursorUI(_loader.movings);
        this.add(_movingCursorUI);
        
        // 通知テキスト
        _infomationUI = new InfomationUI();
        this.add(_infomationUI);

        // スクリプト生成
        _script = new EscScript();
        this.add(_script);

        // タップエフェクト
        _tagUI = new TapUI();
        this.add(_tagUI);
    }

    /**
     * 編集フラグを設定する
     */
    public function setEdit(b:Bool):Void {
        _isEdit = b;
        for(txt in _txts) {
            txt.visible = b;
        }
    }
    public function isEdit():Bool {
        return _isEdit;
    }

    public function getInfomationUI():InfomationUI {
        return _infomationUI;
    }

    /**
     * テキストの追加
     */
    function _addText():FlxText {
        var length:Int = _txts.length;
        var x:Float = 8;
        var y:Float = 8 + (length * 24);
        var txt = new FlxText(x, y);
        var size:Int = 20;
        txt.setFormat(null, size);
        _txts.push(txt);
        return txt;
    }

	/**
	 * クリックしたオブジェクトを取得
	 */
    function _clickObj():EscSprite {
		for(obj in _objs) {
            if(Utils.checkClickSprite(obj)) {
                return obj;
            }
		}

		return null;
    }

    function _clickMovingObj():EscObj {
        return _movingCursorUI.clickObj();
    }

    /**
     * オブジェクトをクリックした時の処理
     */
    function _onClick(obj:EscObj):Void {
        trace('click: ${_loader.getRoot()}${obj.click}.txt');
        var str = obj.getClick();
        if(str == null) {
            return;
        }
        trace(str);

        // スクリプト実行
        _script.execute(str, null);
        _state = State.ScriptWait;
    }

    /**
     * 更新
     */
    public override function update(elapsed:Float):Void {
        super.update(elapsed);

        switch(_state) {
            case State.Execute:
                _updateExecute();
            case State.ScriptWait:
                _movingCursorUI.visible = false;
                if(_script.isEnd()) {
                    if(EscGlobal.hasNextSceneID()) {
                        // 次のシーンに進む
                        _state = State.NextScene;
                    }
                    else {
                        _movingCursorUI.visible = true;
                        _state = State.Execute;
                    }
                }
            case State.NextScene:
                // 次のシーンに進む
                _movingCursorUI.visible = false;
        }

        if(isEdit()) {
            // デバッグ用更新
            _updateDebug();
        }
        else {
            _updateObjVisible();
        }
    }

    function _updateExecute():Void {
		if(FlxG.mouse.justPressed) {
            // タップエフェクト開始
            _tagUI.start(FlxG.mouse.x, FlxG.mouse.y);

            // クリックしたオブジェクトを取得する
			_selobj = _clickObj();
			if(_selobj != null) {
				var width:Float = _selobj.width + 4;
				var height:Float = _selobj.height + 4;
				_selframe.makeGraphic(Std.int(width), Std.int(height), FlxColor.RED);
                _onClick(_selobj.getObj());
			}
            else {
                var obj = _clickMovingObj();
                if(obj != null) {
                    _onClick(obj);
                }
            }
		}
    }

    function _updateObjVisible():Void {
        for(spr in _objs) {
            spr.visible = spr.getObj().checkVisible();
        }
    }

    /**
     * デバッグ表示の更新
     */
    function _updateDebug():Void {

        for(spr in _objs) {
            spr.visible = true;
        }

        if(FlxG.keys.justPressed.Z) {
            // テキストに出力する
            trace("\n" + _loader.build());
        }
        
		var str:String = "";
		_txts[0].text = _loader.bg.getString();
		for(i in 0...2) {
			str = "";
			var obj = _loader.objs[i];
			_txts[i + 1].text = obj.getString();
		}

		_selframe.visible = false;
		if(FlxG.mouse.pressed) {
			if(_selobj != null) {
				// マウスの位置に移動
				_selobj.x = FlxG.mouse.x;
				_selobj.y = FlxG.mouse.y;
				// 枠を表示
				_selframe.visible = true;
				_selframe.x = _selobj.x - 2;
				_selframe.y = _selobj.y - 2;
			}
		}
    }
}
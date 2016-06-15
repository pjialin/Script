PHP常用函数
=======
----------

###Curl请求
>###代码
    /**
	 * @param string $url 地址
	 * @param bool|false $data post数据
	 * @param array $s_option curl参数
	 * @return mixed
	 */
	function curl($url, $data = false,$s_option = []){
		$ch = curl_init();
		$option = [
			CURLOPT_URL => $url,
			CURLOPT_HEADER => 0,
			CURLOPT_FOLLOWLOCATION => TRUE,
			CURLOPT_TIMEOUT => 30,
			CURLOPT_RETURNTRANSFER => TRUE,
			CURLOPT_SSL_VERIFYPEER => 0,
		];
		if ( $data ) {
			$option[CURLOPT_POST] = 1;
			$option[CURLOPT_POSTFIELDS] = http_build_query($data);
		}
		foreach($s_option as $k => $v){
			$option[$k] = $v;
		};
		curl_setopt_array($ch, $option);
		$response = curl_exec($ch);
		if (curl_errno($ch) > 0) {
			exit("CURL ERROR:$url " . curl_error($ch));
		}
		curl_close($ch);
		return $response;
	}

###生成随机字符串
>###代码
	/**
	 * 生成随机字符串
	 * @param $len int 长度
	 * @param $type string 类型
	 */
	function make_str($len=10,$type = 'int')
	{
		$str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$int  = 1234567890;
		switch($type){
			case 'int':
				return substr(str_shuffle(str_repeat($int,$len)),0,$len);
			case 'string':
				return substr(str_shuffle(str_repeat($str.$int,$len)),0,$len);
			default:
				return false;
		}
	}

###输出JSON数据
>###代码
	/**
	 * 输出Json信息
	 * @param Array $data 输出的数据
	 */
	function JSON($data)
	{
		$return['Code'] = I('data.code',0,'',$data);
		if(C('IF_RETURN_INFO'))
			$return['Message'] = I('data.message','' ,'',$data);
		if(C('IF_RETURN_DATA'))
			$return['Data'] = I('data.data','',false,$data);
		die(json_encode($return,JSON_UNESCAPED_UNICODE));
	}
###获取页面完整url
>###代码
	/**
	 * 获取当前页面完整URL地址
	 */
	function get_url() {
		$sys_protocal = isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == '443' ? 'https://' : 'http://';
		$php_self = $_SERVER['PHP_SELF'] ? $_SERVER['PHP_SELF'] : $_SERVER['SCRIPT_NAME'];
		$path_info = isset($_SERVER['PATH_INFO']) ? $_SERVER['PATH_INFO'] : '';
		$relate_url = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : $php_self.(isset($_SERVER['QUERY_STRING']) ? '?'.$_SERVER['QUERY_STRING'] : $path_info);
		return $sys_protocal.(isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : '').$relate_url;
	}
###聚合数据快递查询接口
>###代码
	/**
	 * 查询快递接口
	 * @param Array $info [key,num,com] key 聚合数据调用key num 快递单号 com 快递公司编号
	 */
	protected function select_kd($info = [])
	{
		extract ( $info,EXTR_PREFIX_ALL,'kd');
		$url = 'http://v.juhe.cn/exp/index';
		$data = [
			'com' => $kd_com,
			'no' => $kd_num,
			'key' => $kd_key,
		];
		$result = $this->Curl($url,'POST',$data);
		$res = json_decode($result,true);
		if($res['resultcode'] == 200){
			$resdata['list'] = $res['result']['list'];
			$resdata['status'] = $res['result']['status'];
			$resdata['no'] = $res['result']['no'];
			$resdata['name'] = $res['result']['company'];
			return $resdata;
		}
		return false;
	}
###数组转Xml
>###代码
	/**
	 * 输出xml字符
	 * @param $data array 要转换的字符串
     **/
    protected function ToXml($data)
    {
        $xml = "<xml>";
        foreach ($data as $key=>$val)
        {
            if (is_numeric($val)){
                $xml.="<".$key.">".$val."</".$key.">";
            }else{
                $xml.="<".$key."><![CDATA[".$val."]]></".$key.">";
            }
        }
        $xml.="</xml>";
        return $xml;
    }
###Xml转数组
>###
	/**
	 * 将xml转为array
	 * @param string $xml
	 * @return array
     */
    static public function FromXml($xml)
    {
        //将XML转为array
        //禁止引用外部xml实体
        libxml_disable_entity_loader(true);
        return json_decode(json_encode(simplexml_load_string($xml, 'SimpleXMLElement', LIBXML_NOCDATA)), true);
    }



##微信

###获取access_token
>###代码
	/**
	 * 获取 AccessToken
	 * @param Array $conf [appid,secret,token_dir]
     */
    function get_token($conf = array())
    {
		extract ( $conf,EXTR_PREFIX_ALL,'wx');
        if(file_exists($wx_token_dir) && (time()-filemtime($wx_token_dir)) < 7200){
            return file_get_contents($wx_token_dir);
        }else{
            $url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={$wx_appid}&secret={$wx_secret}";
            $res = $this->Curl($url);
			$res= json_decode($res,true);
            if($token = $res['access_token']){
                file_put_contents($wx_token_dir,$token);
                return $token;
            }
            exit('Error~');
        }
    }
###获取JSAPI_TICKET
>###代码
	/**
	 * 获取 JSAPI_TICKET
	 * @param Array $conf [token,ticket_dir]
	 */
	function get_ticket($conf){
		extract ( $conf,EXTR_PREFIX_ALL,'wx');
		if(file_exists($wx_ticket_dir) && (time()-filemtime($wx_ticket_dir)) < 7200){
			return file_get_contents($wx_ticket_dir);
		}else{
			$url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token={$wx_token}&type=jsapi";
			$res = $this->Curl($url);
			$res= json_decode($res,true);
			if($res['errmsg'] =='ok' && $ticket = $res['ticket']){
				file_put_contents($wx_ticket_dir,$ticket);
				return $ticket;
			}
			exit('Error~');
		}
	}
###微信生成签名
>###代码
	/**
	 * 生成签名 
     */
    protected function make_sign($data){
        ksort($data);
        $str = urldecode(http_build_query($data));
        $str = $str. '&key=' .C('WX_SIGN_KEY');
        return strtoupper(md5($str));
    }

###发送模板消息
>###代码
	/**
     * 发送模板消息
     * $conf['url'] 模板消息点击后的跳转地址
     * $conf['openid'] 接收者openid
     * $conf['id'] 模板id
     *
     * $data Array
     *
     */
    protected function put_tmp($conf,$data)
    {
        $url = 'https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=' . $this->get_token();
       	$conf['template_id'] = $conf['id'];
		$conf['touser'] = $conf['openid'];
        $conf['data'] = $data;
        $res = $this->Curl($url,'POST',json_encode($conf));
        $result = json_decode($res,true);
        if($result['errmsg'] == 'ok'){
            $info['status'] = 1;
        }
        $info['t_id'] = $conf['id'];
        $info['u_openid'] = $conf['openid'];
        $info['content'] = serialize($conf);
        $info['time'] = time();
        $info['result'] = $res;
        M('temp_log')->add($info);
        return $info['status']?true:false;
    }
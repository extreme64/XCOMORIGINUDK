class X_COM_Equipment_Shields extends X_COM_Equipment
	hidecategories(XCOMItem, Inventory, Movement, Debug, Display, Attachment, Collision, Physics, Advanced, Object);

var(XCOM_Shield) const int MaxDefence;
var(XCOM_Shield) const EDamageTypes DefenceFrom;

/** This value will be regenerated each step */
var(XCOM_Shield) const int RegenerationValue;

var(XCOM_Shield) public const MaterialInstance	    ShieldMaterialTemplate; // Template of effect

var public int Defence;
var protected bool bDoRegen;
var protected float RegenStartTime;

public function StartRegeneration();

/** Show static particle effect player unit**/
private function ShowShieldEffect()
{

}

DefaultProperties
{

}

/**
 * HUD class 
 * 
 */
class xcT_DummySender extends object implements (X_COM_Sender);

var public Vector mStart;
var public Vector mEnd;

function vector GetStartingNode()
{
	return mStart;
}

function vector GetDestinationNode()
{
	return mEnd;
}
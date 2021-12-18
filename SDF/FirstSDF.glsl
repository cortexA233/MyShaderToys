const float epsilon = 0.001;
const float maxRayDistance = 10;
const int maxStep = 64;


vec3 BackGround(){
    return vec3(0);
}


vec2 SDFBall(vec3 rayPos, vec3 ballPos){
    float radius = 1.3;
    
    float distanceRayToBallSurface = length(rayPos - ballPos) - radius;   
    int ballID = 1;
    
    return vec2(distanceRayToBallSurface, ballID);
}


vec2 CloserItem(vec2 item1, vec2 item2){
    return item1.x < item2.x ? item1 : item2;
}


vec2 MapWorld(vec3 curRayPos){
    vec2 ball_1 = SDFBall(curRayPos, vec3(0, 0, 0));
    vec2 ball_2 = SDFBall(curRayPos, vec3(1, 1, 1));
    return CloserItem(ball_1, ball_2);
}


vec2 CheckRayHit(in vec3 eyePos, in vec3 rayDir){
    float distance = 1.;
    float currentRayDistance = 0.;
    float finalRayLength = -1.;
    int finalID = -1;

    for(int i = 0; i < maxStep; ++i){
        if(distance < epsilon) break;
        if(currentRayDistance > maxRayDistance) break;

        vec3 curRayPos = eyePos + rayDir * currentRayDistance;
        
        vec2 mapResult = MapWorld(curRayPos);
        float mapDistance = mapResult.x;
        int mapID = mapResult.y;

        finalID = mapID;
        
        currentRayDistance += mapDistance;
    }

    if(currentRayDistance <= maxRayDistance){
        finalRayLength = currentRayDistance;
    }else{
        finalRayLength = -1.;
        finalID = -1;
    }

    return vec2(finalRayLength, finalID);
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec3 color = vec3(1,0,1);
	fragColor = vec4(color,1.0);   
}
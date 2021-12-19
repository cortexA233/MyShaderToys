const float epsilon = 0.0001;
const float maxRayDistance = 10.;
const int maxStep = 222;


mat3 calculateEyeRayTransformationMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}


vec3 BackGround(){
    return vec3(0);
}


vec2 SDFBall(vec3 rayPos, vec3 ballPos, float ID){
    float radius = 0.5;
    
    float distanceRayToBallSurface = length(rayPos - ballPos) - radius;   
    
    return vec2(distanceRayToBallSurface, ID);
}


vec2 CloserItem(vec2 item1, vec2 item2){
    return item1.x < item2.x ? item1 : item2;
}


vec2 MapWorld(vec3 curRayPos){
    vec2 ball_1 = SDFBall(curRayPos, vec3(-0.7, 0, 0), 1.);
    vec2 ball_2 = SDFBall(curRayPos, vec3(0.4, 0.2, 0.5), 2.);
    return CloserItem(ball_1, ball_2);
}


vec2 CheckRayHit(in vec3 eyePos, in vec3 rayDir){
    float distance = 1.;
    float currentRayDistance = 0.;
    float finalRayLength = -1.;
    float finalID = -1.;

    for(int i = 0; i < maxStep; ++i){
        if(distance < epsilon) break;
        if(currentRayDistance > maxRayDistance) break;

        vec3 curRayPos = eyePos + rayDir * currentRayDistance;
        
        vec2 mapResult = MapWorld(curRayPos);
        float mapDistance = mapResult.x;
        float mapID = mapResult.y;

        finalID = mapID;
        
        currentRayDistance += mapDistance;
    }

    if(currentRayDistance <= maxRayDistance){
        finalRayLength = currentRayDistance;
    }else{
        finalRayLength = -1.;
        finalID = -1.;
    }

    return vec2(finalRayLength, finalID);
}

// 这里的参数原本是带in的
vec3 GetSurfaceNormal(vec3 pos){
    vec3 changeX = vec3(0.001, 0., 0.);
    vec3 changeY = vec3(0., 0.001, 0.);
    vec3 changeZ = vec3(0., 0., 0.001);

    float normalX = MapWorld(pos + changeX).x - MapWorld(pos - changeX).x;
    float normalY = MapWorld(pos + changeY).x - MapWorld(pos - changeY).x;
    float normalZ = MapWorld(pos + changeZ).x - MapWorld(pos - changeZ).x;

    return normalize(vec3(normalX, normalY, normalZ));
}


vec3 BallColor(vec3 hitPos, vec3 normal, vec3 color){
    vec3 lightPos = vec3(1., 4., 1.);
    vec3 lightDir = hitPos - lightPos;

    float diff = max(0., dot(lightDir, normal));

    vec3 resultColor = color * diff + vec3(0.8, 0.0118, 0.0118);
    return resultColor;
}


vec3 WorldColor(vec2 rayHitInfo, vec3 eyePos, vec3 rayDir){
    vec3 resultColor = BackGround();
    if(rayHitInfo.y < 0.){
        return resultColor;
    }
    vec3 hitPos = eyePos + rayHitInfo.x * rayDir;
    vec3 normal = GetSurfaceNormal(hitPos);

    if(rayHitInfo.y == 1. || rayHitInfo.y == 2.){
        resultColor = BallColor(hitPos, normal, vec3(1, 1, 1));
    }
    return resultColor;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 p = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;
    vec3 eyePos = vec3(0., 0., 2.);
    vec3 lookAtPos = vec3(0);

    mat3 eyeTransformationMatrix = calculateEyeRayTransformationMatrix(eyePos, lookAtPos, 0.); 

    vec3 rayComeOutDir = normalize(eyeTransformationMatrix * vec3(p.xy, 2.));

    vec2 rayHitInfo = CheckRayHit(eyePos, rayComeOutDir);

    vec3 color = WorldColor(rayHitInfo, eyePos, rayComeOutDir);

    fragColor = vec4(color, 1.);
}
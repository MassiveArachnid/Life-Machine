










#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define degToRad(angleInDegrees) ((angleInDegrees) * M_PI / 180.0)
#define radToDeg(angleInRadians) ((angleInRadians) * 180.0 / M_PI)


typedef struct Cell {
	unsigned int Index;
	unsigned char Class;
	unsigned short TypeID;
	unsigned short UpdateTypeID;
	unsigned int OrganismID;
	//--------------
	float x;
	float y;
	float ox;
	float oy;
	float ParentRot; // The rotation of this cells parent
	float BaseRot; // The base rotation of this cell
	float Bend; // This cells dynamic change to its base rotation
	float Rot; // The real world rotation of this cell
	float ix;
	float iy;
	float iRot;
	unsigned int tx;
	unsigned int ty;
	//--------------
	unsigned char IsCore;
	float ConnectionDist;
	float PullX;
	float PullY;
	float ConnX;
	float ConnY;
	float XVel;
	float YVel;
	float PushX;
	float PushY;
	//--------------
	unsigned char Armor;
	unsigned char Rooted;
	unsigned char Alive;
	float Highlighting;
	float Puffing;
	float Shaking;
	//--------------
	unsigned int Tile;
	unsigned char TileSlot;
	unsigned int TileIncrementTimer;
	//--------------
	unsigned char ChildCount;
	unsigned int Children[3];
	float ChildAngles[3];
	//--------------
	float CustomData[4];
	float Color[3];
} Cell;

typedef struct Debris {
	unsigned int Index;
	unsigned char Class;
	unsigned short TypeID;
	//--------------
	float x;
	float y;
	float Rot; // The real world rotation of this cell
	float ix;
	float iy;
	float iRot;
	//--------------
	float Spin;
	float XVel;
	float YVel;
	//--------------
	float LifeTime;
	unsigned int EggGenomeID;
	float HatchTimer;
	float HatchTimerMax;
	unsigned char Active;
} Debris;

typedef struct Organism {
	unsigned char Dying;
	unsigned char Alive;
	float Health;
	float HealthMax;
	float Energy;
	float EnergyMax;
	float EnergyLossSec;
	float Age;
	unsigned int CoreIndex;
	unsigned int Index;
	//-----------------------
	float CallTimer;
	float CallTimerMax;
	unsigned char Calling;
	float CallProgress;
	float CallDuration;
	float CallX;
	float CallY;
	//-----------------------
	unsigned char CanMoveX;
	unsigned char CanMoveY;
	float MoveX;
	float MoveY;
	float MoveR;
	float XVel;
	float YVel;
	float RVel;
	float Rot;
	//-----------------------
	unsigned short CellCount;
	unsigned int EggType;
	float EggHatchTime;
	unsigned int GenomeIndex;
	float EggCost;
} Organism;

typedef struct MapTile {
	unsigned char Occupancy;
	unsigned int Bucket[8];
	unsigned char Terrain;
	float Sunlight;
	short Temperature;
	float Pressure;
	float Salinity;
	float Oxygen;
	float Color[3];
	float BgTint;
} MapTile;

typedef struct Effect {
	unsigned short Type;
	float x;
	float y;
} Effect;

typedef struct ModuleData {
	// ---------------------------
	// cell debris and organism data
	unsigned int CellCount;
	unsigned int DebrisCount;
	unsigned int OrganismCount;
	unsigned int CellListSize;
	unsigned int DebrisListSize;
	unsigned int OrganismListSize;
	Cell Cells[1000001];
	Debris Debris[1000001];
	Organism Organisms[1000001];	
	// ---------------------------
	unsigned int EffectCount;
	Effect Effects[100000];
	// ---------------------------
	// holds the indexes of freed slots in the above tables
	unsigned int FreeCellSlotCount;
	unsigned int FreeDebrisSlotCount;
	unsigned int FreeOrganismSlotCount;
	unsigned int FreeCellSlots[1000001];
	unsigned int FreeDebrisSlots[1000001];
	unsigned int FreeOrganismSlots[1000001];
	// ---------------------------
	// render lists
	unsigned int CellRenderCount;
	unsigned int DebrisRenderCount;
	unsigned int EffectRenderCount;
	unsigned int CellRenderList[1000001];
	unsigned int DebrisRenderList[1000001];
	unsigned int Safe_CellRenderCount;
	unsigned int Safe_DebrisRenderCount;
	unsigned int Safe_EffectRenderCount;
	unsigned int Safe_CellRenderList[1000001];
	unsigned int Safe_DebrisRenderList[1000001];
	unsigned int Safe_EffectRenderList[1000001];
	// ---------------------------
	// Lists for genome removals
	unsigned int GenomeRemovalsCount;
	unsigned int GenomeRemovals[1000001];
	// ---------------------------
	// other data
	float CamBounds[4];
	unsigned int MapSize;
	float Gravity;
	float HalfSize;
	unsigned int CellLimit;
	unsigned int DebrisLimit;
	unsigned int OrganismLimit;
} ModuleData;

/////////// UTIL FUNCTIONS
inline double distance(double x1, double y1, double x2, double y2) {
    double square_difference_x = (x2 - x1) * (x2 - x1);
    double square_difference_y = (y2 - y1) * (y2 - y1);
    double sum = square_difference_x + square_difference_y;
    double value = sqrt(sum);
    return value;
}
inline double clamp(double d, double min, double max) {
  const double t = d < min ? min : d;
  return t > max ? max : t;
}
float clampf(float d, float min, float max) {
  const float t = d < min ? min : d;
  return t > max ? max : t;
}
inline float lerp(float a, float b, float f) {
    return a + f * (b - a);
}
inline float to_degrees(double radians) {
    return radians * (180.0 / M_PI);
}
inline float OffsetToAngle(float x, float y) {
	float v = -radToDeg(atan2(-y, x)-degToRad(90));
    if (v < 0) { 
		return v + 360;
	} else {
		return v;
	}
}
inline void NewEffect(struct ModuleData *MD, unsigned short Type, float x, float y) {
	if (MD->EffectCount < 100000) {
		MD->EffectCount += 1;
		MD->Effects[MD->EffectCount].Type = Type;
		MD->Effects[MD->EffectCount].x = x;
		MD->Effects[MD->EffectCount].y = y;	
	}
}
inline void CreateDebris(struct ModuleData *MD, unsigned short Type, float x, float y) {

	if (MD->FreeDebrisSlotCount > 0) {
		int NewIndex = MD->FreeDebrisSlots[MD->FreeDebrisSlotCount];
		MD->FreeDebrisSlotCount -= 1;
		if (NewIndex > MD->DebrisListSize) {		
			MD->DebrisListSize = NewIndex;
		}
		MD->DebrisCount += 1;
		
		MD->Debris[NewIndex].Index = NewIndex;
		MD->Debris[NewIndex].Class = 1;
		MD->Debris[NewIndex].TypeID = Type;
		MD->Debris[NewIndex].x = x;
		MD->Debris[NewIndex].y = y;
		MD->Debris[NewIndex].Rot = rand() % 360;
		MD->Debris[NewIndex].ix = x;
		MD->Debris[NewIndex].iy = y;
		MD->Debris[NewIndex].iRot = 0;
		MD->Debris[NewIndex].Spin = rand() % 25;
		MD->Debris[NewIndex].XVel = 0;
		MD->Debris[NewIndex].YVel = 0;
		MD->Debris[NewIndex].LifeTime = 10 + (rand() % 20);
		MD->Debris[NewIndex].EggGenomeID = 0;
		MD->Debris[NewIndex].HatchTimer = 0;
		MD->Debris[NewIndex].HatchTimerMax = 0;
		MD->Debris[NewIndex].Active = 1;
	}
}


/////////// SWITCH FUNCTIONS
inline void CollisionUpdate(float dt, unsigned int MapSize, MapTile *Map, Organism *Organisms, unsigned int o, Debris *Debris, Cell *Cells, unsigned int k, unsigned int j, unsigned char DebrisCollision, struct ModuleData *MD) {
	switch (Cells[k].UpdateTypeID) {
		case 1: break;
		case 2: 
			if (DebrisCollision == 1 && Debris[j].TypeID == Cells[k].CustomData[0]) {
				Organisms[o].Energy -= Cells[k].CustomData[2];
				Debris[j].LifeTime = 0;
				CreateDebris(MD, Cells[k].CustomData[1], Debris[j].x, Debris[j].y);
				NewEffect(MD, 2, Debris[j].x, Debris[j].y);
				if (Cells[k].Puffing < 0.1) {
					Cells[k].Puffing = 0.5;
					Cells[k].Highlighting = 1;
				}
			}
			break;
		case 3: 
			if (DebrisCollision == 0 && Cells[k].CustomData[2] <= 0) {  // Poke other organisms on cooldown
				NewEffect(MD, 4, Cells[j].x, Cells[j].y);
				Organisms[Cells[j].OrganismID].Health -= clamp(Cells[k].CustomData[0] - Cells[j].Armor, 0, 9999999);
				Cells[k].CustomData[2] = Cells[k].CustomData[1];
			}
			if (Cells[k].Shaking < 0.1) {
				//Cells[k].Puffing = 0.5;
				//Cells[k].Highlighting = 1;
				//Cells[k].Shaking = 1;
			}
			break;
		case 4: break;
		case 5: break;
		case 6: 
			if (DebrisCollision == 1 && Debris[j].TypeID == Cells[k].CustomData[0] && Debris[j].LifeTime > 0) {
				NewEffect(MD, 1, Debris[j].x, Debris[j].y);
				Organisms[o].Energy += Cells[k].CustomData[1];
				Debris[j].LifeTime = 0;
				if (Cells[k].Puffing < 0.1) {
					Cells[k].Puffing = 0.5;
					Cells[k].Highlighting = 1;
				}
			}
			break;
		
		case 7: break;
		case 8: break;
	}	
}
inline void PassiveUpdate(float dt, unsigned int MapSize, MapTile *Map, Organism *Organisms, unsigned int o, Cell *Cells, unsigned int k, struct ModuleData *MD) {
	switch (Cells[k].UpdateTypeID) {
		case 1: break;
		case 2: break;
		case 3: 
			if (Cells[k].CustomData[2] > 0) {
				Cells[k].CustomData[2] -= dt;
			}
			break;
		case 4: 
			float Offx = -sin(degToRad(Cells[k].Rot+180)) * dt * (1.45 * Cells[k].CustomData[0]);
			float Offy = cos(degToRad(Cells[k].Rot+180)) * dt * (1.45 * Cells[k].CustomData[0]);
			float x1 = Cells[k].x - Cells[Organisms[o].CoreIndex].x;
			float y1 = Cells[k].y - Cells[Organisms[o].CoreIndex].y;
			float x2 = x1 + Offx;
			float y2 = y1 + Offx;
			float ang_1 = OffsetToAngle(x1, y1);
			float ang_2 = OffsetToAngle(x2, y2);
			
			Organisms[o].XVel += Offx;
			Organisms[o].YVel += Offy;
			Organisms[o].RVel += (ang_1-ang_2) * dt * 0.1;
			
			break;
		case 5: break;
		case 6: break;
		case 7: 
			Cells[k].CustomData[2] += dt * 2;
			Cells[k].Bend = Cells[k].BaseRot + (30 * sin(Cells[k].CustomData[2]));		
			break;
		
		case 8: // Photosynth 			
			Organisms[o].Energy += Map[(Cells[k].tx * MapSize) + Cells[k].ty].Sunlight * 1 * dt;

			break;
	}	
}

float CellPushForce = 0.3;
unsigned char MapEdge = 10;
unsigned int TILES[4];
float MoveX, MoveY, DirX, DirY, XForce, YForce = 0;
float ConnectionRange = 0.7;
float UnitSize = 0.99;
float DSize = 0.1;
unsigned int DesiredTX, DesiredTY = 0;
float DesiredRot;
unsigned int OrgID;
unsigned int Org2ID;
int k, s, b, i;
int CollisionTile_1, CollisionTile_2;
unsigned int TileReCheckIncrement = 10000;
unsigned int TI;
unsigned char Colliding;

int tst = 0;
int ff;
	

	
unsigned int Process(float dt, MapTile *Map, struct ModuleData *MD) {
	
	float x1 = MD->CamBounds[0];
	float x2 = MD->CamBounds[1];
	float y1 = MD->CamBounds[2];
	float y2 = MD->CamBounds[3];
	float Gravity = MD->Gravity;
	float HalfSize = MD->HalfSize;
	unsigned int MapSize = MD->MapSize;	
	
	unsigned int CI, tx, ty;
	
	Cell *Cells = MD->Cells;
	Debris *Debris = MD->Debris;
	Organism *Organisms = MD->Organisms;	
	
	float DebrisBounceStr = 1.5;
	
	unsigned int iter = 0;
	
	int debug = 1;


	for (k=1; k <= MD->CellListSize; k++) {	
		
		OrgID = Cells[k].OrganismID;
		
		if (Cells[k].Alive == 1) {
			
			PassiveUpdate(dt, MapSize, Map, Organisms, OrgID, Cells, k, MD);
			
			if (Cells[k].IsCore == 1) {
				Cells[k].ConnX = Cells[k].x;
				Cells[k].ConnY = Cells[k].y;
			}
			
			Cells[k].PullX = clamp(Cells[k].ConnX - Cells[k].x, -ConnectionRange, ConnectionRange);
			Cells[k].PullY = clamp(Cells[k].ConnY - Cells[k].y, -ConnectionRange, ConnectionRange);			
			DirX = clamp((Organisms[OrgID].MoveX / Organisms[OrgID].CellCount)+Cells[k].PullX, -4, 4);
			DirY = clamp((Organisms[OrgID].MoveY / Organisms[OrgID].CellCount)+Cells[k].PullY, -4, 4);
			MoveX = Cells[k].x + DirX;
			MoveY = Cells[k].y + DirY;
			
			if (MoveX <= MapEdge || MoveX >= MapSize-MapEdge) {
				Organisms[OrgID].XVel = 0;
				//Organisms[OrgID].MoveX = 0;				
				MoveX = Cells[k].x;
				if (Organisms[OrgID].MoveX < 0) {
					Organisms[OrgID].XVel += 1 * Organisms[OrgID].CellCount;
				} else {
					Organisms[OrgID].XVel -= 1 * Organisms[OrgID].CellCount;
				}
			}
			if (MoveY <= MapEdge || MoveY >= MapSize-MapEdge) {
				Organisms[OrgID].YVel = 0;
				//Organisms[OrgID].MoveY = 0;
				MoveY = Cells[k].y;
				if (Organisms[OrgID].MoveY < 0) {
					Organisms[OrgID].YVel += 1 * Organisms[OrgID].CellCount;
				} else {
					Organisms[OrgID].YVel -= 1 * Organisms[OrgID].CellCount;
				}
			}
			
			DesiredTX = floor(MoveX - UnitSize);
			DesiredTY = floor(MoveY - UnitSize);
			TILES[0] = (DesiredTX * MapSize) + DesiredTY;
			TILES[1] = ((DesiredTX + 1) * MapSize) + DesiredTY;
			TILES[2] = (DesiredTX * MapSize) + (DesiredTY + 1);
			TILES[3] = ((DesiredTX + 1) * MapSize) + (DesiredTY + 1);
			//Cells[k].XVel = lerp(Cells[k].XVel, 0, dt * 1)
			//Cells[k].YVel = lerp(Cells[k].YVel, 0, dt * 1)			
			
			Cells[k].Puffing = lerp(Cells[k].Puffing, 0, dt*4);
			Cells[k].Highlighting = lerp(Cells[k].Highlighting, 0, dt*4);
			Cells[k].Shaking = lerp(Cells[k].Shaking, 0, dt*4);
			
			if (debug == 1) {
				for (b=1; b <= MD->CellListSize; b++) {	 
					if (k != b) {
						if (Cells[k].OrganismID != Cells[b].OrganismID) {
							
							Org2ID = Cells[b].OrganismID;
							Colliding = 0;
							// Put a bunch of force on units overlapping us (probably spawned on the unit)
							
							if (abs(Cells[k].x-Cells[b].x)+abs(Cells[k].y-Cells[b].y) < 0.99) {
								Cells[k].XVel += (rand() % 2) - 1;
								Cells[k].YVel += (rand() % 2) - 1;
								Colliding = 1;
							}							
							
							if (abs(MoveX-Cells[b].x)+abs(Cells[k].y-Cells[b].y) <= 0.99) {
								Colliding = 1;
								MoveX = Cells[k].x;
								XForce = Organisms[OrgID].XVel+(Cells[k].PullX*1);
								Organisms[Org2ID].XVel += XForce;
								Organisms[OrgID].XVel = 0;
								if (Cells[Organisms[Org2ID].CoreIndex].y < Cells[b].y) {
									if (XForce < 0) {
										Organisms[Org2ID].RVel += XForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel -= XForce / Organisms[Org2ID].CellCount * dt * 100;
									}
								} else {
									if (XForce < 0) {
										Organisms[Org2ID].RVel -= XForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel += XForce / Organisms[Org2ID].CellCount * dt * 100;
									}						
								}						
							}				
							
							if (abs(Cells[k].x-Cells[b].x)+abs(MoveY-Cells[b].y) <= 0.99) {
								Colliding = 1;
								MoveY = Cells[k].y;
								YForce = Organisms[OrgID].YVel+(Cells[k].PullY*1);
								Organisms[Org2ID].YVel += YForce;
								Organisms[OrgID].YVel = 0;
								if (Cells[Organisms[b].CoreIndex].x < Cells[b].x) {
									if (YForce < 0) {
										Organisms[Org2ID].RVel += YForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel -= YForce / Organisms[Org2ID].CellCount * dt * 100;
									}
								} else {
									if (YForce < 0) {
										Organisms[Org2ID].RVel -= YForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel += YForce / Organisms[Org2ID].CellCount * dt * 100;
									}						
								}	
							}							
							
							if (abs(MoveX-Cells[b].x)+abs(MoveY-Cells[b].y) <= 0.99) {
								MoveX = Cells[k].x;
								MoveY = Cells[k].y;
								//Cells[k].XVel = 0
							   // Cells[k].YVel = 0
							}
							if (Colliding == 1) {
								CollisionUpdate(dt, MapSize, Map, Organisms, Cells[b].OrganismID, Debris, Cells, b, k, 0, MD);
							}
						}
					}
				}
			}
			
			if (debug == 0) {
				// ----------------------------------
				// Push on / Interact with nearby units
				for (s=0; s <= 3; s++) {	 
					for (i=0; i < Map[TILES[s]].Occupancy; i++) {	
						b = Map[TILES[s]].Bucket[i];
						if (k != b && Cells[k].OrganismID != Cells[b].OrganismID) {
							
							Colliding = 0;
							
							Org2ID = Cells[b].OrganismID;
							
							// Put a bunch of force on units overlapping us (probably spawned on the unit)
							
							if (sqrt(pow(Cells[k].x - Cells[b].x, 2) + pow(Cells[k].y - Cells[b].y, 2)) < HalfSize) {
								Cells[k].XVel += 1;
								Cells[k].YVel += 1;
								Colliding = 1;
							}							
							
							if (sqrt(pow(MoveX - Cells[b].x, 2) + pow(Cells[k].y - Cells[b].y, 2)) <= HalfSize) {
								Colliding = 1;
								MoveX = Cells[k].x;
								XForce = Organisms[OrgID].XVel+(Cells[k].PullX*1);
								Organisms[Org2ID].XVel = XForce;
								Organisms[OrgID].XVel = 0;
								Organisms[OrgID].CanMoveX = 0;
								if (Cells[Organisms[Org2ID].CoreIndex].y < Cells[b].y) {
									if (XForce < 0) {
										Organisms[Org2ID].RVel += XForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel -= XForce / Organisms[Org2ID].CellCount * dt * 100;
									}
								} else {
									if (XForce < 0) {
										Organisms[Org2ID].RVel -= XForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel += XForce / Organisms[Org2ID].CellCount * dt * 100;
									}						
								}						
							}				
							
							if (sqrt(pow(Cells[k].x - Cells[b].x, 2) + pow(MoveY - Cells[b].y, 2)) <= HalfSize) {
								Colliding = 1;
								MoveY = Cells[k].y;
								YForce = Organisms[OrgID].YVel+(Cells[k].PullY*1);
								Organisms[Org2ID].YVel = YForce;
								Organisms[OrgID].YVel = 0;
								Organisms[OrgID].CanMoveY = 0;
								if (Cells[Organisms[b].CoreIndex].x < Cells[b].x) {
									if (YForce < 0) {
										Organisms[Org2ID].RVel += YForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel -= YForce / Organisms[Org2ID].CellCount * dt * 100;
									}
								} else {
									if (YForce < 0) {
										Organisms[Org2ID].RVel -= YForce / Organisms[Org2ID].CellCount * dt * 100;
									} else {
										Organisms[Org2ID].RVel += YForce / Organisms[Org2ID].CellCount * dt * 100;
									}						
								}	
							}							
							
							if (sqrt(pow(MoveX - Cells[b].x, 2) + pow(MoveY - Cells[b].y, 2)) <= HalfSize) {
								Colliding = 1;
								MoveX = Cells[k].x;
								MoveY = Cells[k].y;
								//Cells[k].XVel = 0
							   // Cells[k].YVel = 0
							}
							
							if (Colliding == 1) {
								CollisionUpdate(dt, MapSize, Map, Organisms, Cells[b].OrganismID, Debris, Cells, k, b, 0, MD);
							}
						}
					}
				}
			}

			////////////////////////////////////
			// Update connections and rotations
			Cells[k].Rot = Cells[k].ParentRot + Cells[k].BaseRot + Cells[k].Bend;
			for (s=0; s < Cells[k].ChildCount; s++) {	 
				b = Cells[k].Children[s];
				// Store this cells current rotation in its children every frame
				Cells[b].ParentRot = Cells[k].Rot;
				DesiredRot = degToRad(Cells[k].Rot + Cells[b].BaseRot);			


				//Cells[b].ConnX = Cells[k].ConnX + (Cells[b].ox * ConnectionRange);				
				//Cells[b].ConnY = Cells[k].ConnY + (Cells[b].oy * ConnectionRange);
				
				Cells[b].ConnX = Cells[k].ConnX + ((Cells[b].ox * cos(DesiredRot) - Cells[b].oy * sin(DesiredRot)) * ConnectionRange);				
				Cells[b].ConnY = Cells[k].ConnY + ((Cells[b].oy * cos(DesiredRot) + Cells[b].ox * sin(DesiredRot)) * ConnectionRange);
				
				//Cells[b].ConnX = Cells[k].ConnX + (sin(degToRad(DesiredRot)) * (ConnectionRange*Cells[b].ConnectionDist));
				// Cells[b].ConnY = Cells[k].ConnY - (cos(degToRad(DesiredRot)) * (ConnectionRange*Cells[b].ConnectionDist));
			}
			
			////////////////////////////////////
			// Velocity - collide with units and terrain
			if (Cells[k].Rooted == 0) {
		
				if (Map[TILES[0]].Terrain == 0) {
					Cells[k].x = MoveX;						
					Cells[k].y = MoveY;						
				} else {
					if (Cells[k].UpdateTypeID == 1) { Cells[k].Rooted = 1;}    			
					if (Cells[k].x-(floor(MoveX)+0.5) > 0) {
						Organisms[OrgID].XVel += 0.5 * Organisms[OrgID].CellCount;
					} else {
						Organisms[OrgID].XVel += -0.5 * Organisms[OrgID].CellCount;
					}
					if (Cells[k].y-(floor(MoveY)+0.5) > 0) {
						Organisms[OrgID].YVel += 0.5 * Organisms[OrgID].CellCount;
					} else {
						Organisms[OrgID].YVel += -0.5 * Organisms[OrgID].CellCount;
					}					
				}

			}
			
			tx = floor(Cells[k].x);
			ty = floor(Cells[k].y);
			Cells[k].tx = tx;
			Cells[k].ty = ty;
			if (Organisms[OrgID].Dying == 1) {
				Cells[k].Alive = 0;
				MD->FreeCellSlotCount += 1;
				MD->FreeCellSlots[MD->FreeCellSlotCount] = k;			
				MD->CellCount -= 1;
			}

			// ----------------------------------
			// Change tiles if we are dead, if we moved a tile, or just periodically for cells that spawned on a full bucket and havent moved
			if (debug == 0) {
				if (Cells[k].Alive == 0 || Cells[k].tx-tx != 0 || Cells[k].ty-ty != 0 || Cells[k].TileIncrementTimer <= 0) {
					Cells[k].TileIncrementTimer = TileReCheckIncrement;
					Cells[k].tx = tx;
					Cells[k].ty = ty;
					TI = Cells[k].Tile;

					// Clear out of old tiles and pack them down when we remove ourself
					if (Cells[k].TileSlot != 255) {
						Map[TI].Bucket[Cells[k].TileSlot] = 0; // keep, neccesary to clear out self in a single occupannt tile
						for (i=Cells[k].TileSlot; i < Map[TI].Occupancy; i++) {	
							Map[TI].Bucket[i] = Map[TI].Bucket[i + 1];
							Map[TI].Bucket[i + 1] = 0;
						}
						Map[TI].Occupancy -= 1;
					}

					// Add self back into map after removal
					if (Cells[k].Alive == 1) {
						// Determine new tiles
						Cells[k].Tile = (tx * MapSize) + ty;
						// Put self down in nearby buckets, if the bucket is full, flag the units tile slot for this tile as 255 (couldnt fit in bucket)
						if (Map[Cells[k].Tile].Occupancy < 8) {
							Map[Cells[k].Tile].Bucket[Map[Cells[k].Tile].Occupancy] = k;
							Map[Cells[k].Tile].Occupancy += 1;
							Cells[k].TileSlot = Map[Cells[k].Tile].Occupancy;
						} else {
							Cells[k].TileSlot = 255;
						}
					}
				}
				Cells[k].TileIncrementTimer -= 1;
			}

			////////////////////////////////////
			// Add an entry to the render list if in range		
			if (Cells[k].x >= x1 && Cells[k].x <= x2 && Cells[k].y >= y1 && Cells[k].y <= y2) {
				MD->CellRenderCount += 1;
				MD->CellRenderList[MD->CellRenderCount] = k;
			}
				
		}
		
	}

	for (k=1; k <= MD->DebrisListSize; k++) {
		
		if (Debris[k].Active == 1) {
			
			// Debug simulate current for debris
			Debris[k].XVel += sin(k) * 0.001;
			Debris[k].YVel += Gravity * 0.1 * dt * 0.3;
			
			// Clamp velocity so that we cant tunnel through terrain tiles
			MoveX = clamp(Debris[k].x+clamp(Debris[k].XVel, -4, 4), MapEdge, MapSize-MapEdge);
			MoveY = clamp(Debris[k].y+clamp(Debris[k].YVel, -4, 4), MapEdge, MapSize-MapEdge);
		
			DesiredTX = floor(MoveX - UnitSize);
			DesiredTY = floor(MoveY - UnitSize);
			TILES[0] = (DesiredTX * MapSize) + DesiredTY;
			TILES[1] = ((DesiredTX + 1) * MapSize) + DesiredTY;
			TILES[2] = (DesiredTX * MapSize) + (DesiredTY + 1);
			TILES[3] = ((DesiredTX + 1) * MapSize) + (DesiredTY + 1);	
			Debris[k].XVel = lerp(Debris[k].XVel, 0, dt*1);
			Debris[k].YVel = lerp(Debris[k].YVel, 0, dt*1);		
			
			if (debug == 1) {
				// ----------------------------------
				// Push on / Interact with nearby units
				for (b=1; b <= MD->CellListSize; b++) {	 					
					// Put a bunch of force on ourself if any cells overlapping us	
					//if (distance(Debris[k].x, Debris[k].y, Cells[b].x, Cells[b].y) < 0.99/2) {
					if (Cells[b].Alive == 1 && abs(MoveX-Cells[b].x)+abs(MoveY-Cells[b].y) <= 0.99) {
						if (Debris[k].x < Cells[b].x) {
							if (Debris[k].XVel > 0) {
								Debris[k].XVel = 0;
							}
							Debris[k].XVel -= DebrisBounceStr * dt;
						} else {
							if (Debris[k].XVel < 0) {
								Debris[k].XVel = 0;
							}
							Debris[k].XVel += DebrisBounceStr * dt;
						}
						if (Debris[k].y < Cells[b].y) {
							if (Debris[k].YVel > 0) {
								Debris[k].YVel = 0;
							}
							Debris[k].YVel -= DebrisBounceStr * dt;
						} else {
							if (Debris[k].YVel < 0) {
								Debris[k].YVel = 0;
							}
							Debris[k].YVel += DebrisBounceStr * dt;
						}
						
						CollisionUpdate(dt, MapSize, Map, Organisms, Cells[b].OrganismID, Debris, Cells, b, k, 1, MD);
						
					}
				}
			}
			
			if (debug == 0) {
				// ----------------------------------
				// Push on / Interact with nearby units
				for (s=0; s <= 3; s++) {	 
					for (i=0; i < Map[TILES[s]].Occupancy; i++) {	
						b = Map[TILES[s]].Bucket[i];
						// Put a bunch of force on ourself if any cells overlapping us
						if (abs(Debris[k].x-Cells[b].x)+abs(Debris[k].y-Cells[b].y) < HalfSize) {
						//if (sqrt(pow(Debris[k].x - Cells[b].x, 2) + pow(Debris[k].y - Cells[b].y, 2)) < HalfSize) {
							if (Debris[k].x < Cells[b].x) {
								if (Debris[k].XVel > 0) {
									Debris[k].XVel = 0;
								}
								Debris[k].XVel -= DebrisBounceStr * dt;
							} else {
								if (Debris[k].XVel < 0) {
									Debris[k].XVel = 0;
								}
								Debris[k].XVel += DebrisBounceStr * dt;
							}
							if (Debris[k].y < Cells[b].y) {
								if (Debris[k].YVel > 0) {
									Debris[k].YVel = 0;
								}
								Debris[k].YVel -= DebrisBounceStr * dt;
							} else {
								if (Debris[k].YVel < 0) {
									Debris[k].YVel = 0;
								}
								Debris[k].YVel += DebrisBounceStr * dt;
							}
							
							//local CellTypeTable = Types["Cell"][b.Type];
							CollisionUpdate(dt, MapSize, Map, Organisms, Cells[b].OrganismID, Debris, Cells, b, k, 1, MD);
							goto done;
						}
					}
				}
				done:
			}
			
			//------------------------------------
			// Velocity - collide with units and terrain
			CollisionTile_1 = (floor(MoveX) * MapSize) + floor(Debris[k].y);
			CollisionTile_2 = (floor(Debris[k].x) * MapSize) + floor(MoveY);
			
			if (Map[CollisionTile_1].Terrain == 0) {
				Debris[k].x = MoveX;
			} else {
				Debris[k].XVel = (-Debris[k].XVel)*0.3;
			}
			if (Map[CollisionTile_2].Terrain == 0) {
				Debris[k].y = MoveY;
			} else {
				Debris[k].YVel = (-Debris[k].YVel)*0.3;
			}		

			if (Debris[k].x >= x1 && Debris[k].x <= x2 && Debris[k].y >= y1 && Debris[k].y <= y2) {
				MD->DebrisRenderCount += 1;
				MD->DebrisRenderList[MD->DebrisRenderCount] = k;
			}		
			
			if (Debris[k].EggGenomeID != 0) {
				Debris[k].HatchTimer += dt;
			}			
			
			Debris[k].LifeTime -= dt;
			if (Debris[k].LifeTime <= 0) {
				Debris[k].Active = 0;
				MD->FreeDebrisSlotCount += 1;
				MD->FreeDebrisSlots[MD->FreeDebrisSlotCount] = k;
				MD->DebrisCount -= 1;
			}
		}	
	
		
	}	
	
	for (k=1; k <= MD->OrganismListSize; k++) {	
			
		if (Organisms[k].Alive == 1) {
			
			CI = Organisms[k].CoreIndex;
			//Organisms[k].XVel = 5;
			
			// set the forces that will be applied to all organism cells next update
			Organisms[k].MoveX = Organisms[k].XVel;
			Organisms[k].MoveY = Organisms[k].YVel;
			Organisms[k].MoveR = Organisms[k].RVel;
			
			// Reset forces
			Organisms[k].XVel = lerp(Organisms[k].XVel, 0, dt * 1);
			Organisms[k].YVel = lerp(Organisms[k].YVel, 0, dt * 1);
			Organisms[k].RVel = lerp(Organisms[k].RVel, 0, dt * 1);
			
			Cells[CI].BaseRot += Organisms[k].RVel;
			Cells[CI].BaseRot = fmod(Cells[CI].BaseRot, 360);
			if (Cells[CI].BaseRot < 0) {
				Cells[CI].BaseRot += 360;
			}
			
			Organisms[k].YVel += Gravity * dt;			
			
			if (Organisms[k].Health <= 0 && Organisms[k].Dying == 0) {
				NewEffect(MD, 5, Cells[CI].x, Cells[CI].y);
				Organisms[k].Dying = 1;
			}			
			
			if (Organisms[k].Dying == 1) {
				Organisms[k].Alive = 0;
				MD->FreeOrganismSlotCount += 1;
				MD->FreeOrganismSlots[MD->FreeOrganismSlotCount] = k;
				MD->OrganismCount -= 1;
				MD->GenomeRemovalsCount += 1;
				MD->GenomeRemovals[MD->GenomeRemovalsCount] = Organisms[k].GenomeIndex;
				NewEffect(MD, 3, Cells[CI].x, Cells[CI].y);
			}
			
			Organisms[k].CallTimer -= dt;
			if (Organisms[k].CallTimer <= 0) {
				Organisms[k].CallTimer = Organisms[k].CallTimerMax;
				Organisms[k].CallX = Cells[CI].x;
				Organisms[k].CallY = Cells[CI].y;
				Organisms[k].Calling = 1;
				Organisms[k].CallProgress = 0;
				//Organisms[k].Energy -= Organisms[k].EnergyMax * 0.05;
			}
			
			if (Organisms[k].Calling == 1) {
				Organisms[k].CallProgress += dt;
				if (Organisms[k].CallProgress >= Organisms[k].CallDuration) {
					Organisms[k].CallProgress = 0;
					Organisms[k].Calling = 0;
				}				
			}
			
			Organisms[k].Age += dt;
			
			//Organisms[k].Energy = 0;
			Organisms[k].Energy = clamp(Organisms[k].Energy-(Organisms[k].EnergyLossSec * 0.2 * dt), 0, Organisms[k].EnergyMax+Organisms[k].EggCost);
			

			if (Organisms[k].Energy == 0) {
				Organisms[k].Dying = 1; // We have a 'dying' flag as well to give the units under this organism a pass to remove them selves before the organism is gone (and possibly replaced)
			}
			
			
		}

	}


	
	
return iter;
}

















































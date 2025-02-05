






_CDEFS = [[
    


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
	





////////////////////////////////////////////////////////////

void* malloc(size_t);                   
void free(void*);
]]



ffi.cdef(_CDEFS)












